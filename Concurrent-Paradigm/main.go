//To run program, type into cmd: go run main.go "filename" 0.99 0.5 0.5

package main

import (
	"bufio"
	"fmt"
	"math"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"
)

type Point3D struct {
	X float64
	Y float64
	Z float64
}

type Plane3D struct {
	A float64
	B float64
	C float64
	D float64
}

type Plane3DwSupport struct {
	Plane3D
	SupportSize int
}

// ReadXYZ reads an XYZ file and returns a slice of Point3D
func ReadXYZ(filename string) []Point3D {

	// read file into slice of line strings
	file, _ := os.Open(filename)
	defer file.Close()

	var input []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		input = append(input, scanner.Text())
	}

	// break down strings
	var input2 []string
	for i := 1; i < len(input); i++ {
		s := strings.Fields(input[i])
		input2 = append(input2, s...)
	}

	// create slice of float64
	var sliceFloats []float64

	for i := 0; i < len(input2); i++ {
		f64, _ := strconv.ParseFloat(input2[i], 64)
		sliceFloats = append(sliceFloats, f64)
	}

	// create a slice of Point3D
	var slicePoint3D []Point3D
	for i := 0; i < len(sliceFloats)-1; i += 3 {
		slicePoint3D = append(slicePoint3D, Point3D{sliceFloats[i], sliceFloats[i+1], sliceFloats[i+2]})
	}

	return slicePoint3D
}

// SaveXYZ saves a slice of Point3D into an XYZ file
func SaveXYZ(filename string, points []Point3D) {

	file, _ := os.Create(filename + ".xyz")
	defer file.Close()
	file.WriteString("x      y      z\n")

	for i := 0; i < len(points); i++ {
		x := fmt.Sprintf("%f", points[i].X)
		y := fmt.Sprintf("%f", points[i].Y)
		z := fmt.Sprintf("%f", points[i].Z)
		file.WriteString(x + " " + y + " " + z + "\n")
	}

	/*for i := range points {
		fmt.Fprintln(file, points[i])
	}*/
}

// GetDistance computes the distance between points p1 and p2
func (p1 *Point3D) GetDistance(p2 *Point3D) float64 {
	var dist float64
	dist = math.Sqrt((p2.X-p1.X)*(p2.X-p1.X) + (p2.Y-p1.Y)*(p2.Y-p1.Y) + (p2.Z-p1.Z)*(p2.Z-p1.Z))
	return dist
}

// GetPlane computes the plane defined by a set of 3 points
func GetPlane(points []Point3D) Plane3D {
	p1 := Point3D{
		points[0].X,
		points[0].Y,
		points[0].Z,
	}
	p2 := Point3D{
		points[1].X,
		points[1].Y,
		points[1].Z,
	}
	p3 := Point3D{
		points[2].X,
		points[2].Y,
		points[2].Z,
	}
	var a, b, c, d float64
	a = (p2.Y-p1.Y)*(p3.Z-p1.Z) - (p3.Y-p1.Y)*(p2.Z-p1.Z)
	b = (p3.X-p1.X)*(p2.Z-p1.Z) - (p2.X-p1.X)*(p3.Z-p1.Z)
	c = (p2.X-p1.X)*(p3.Y-p1.Y) - (p2.Y-p1.Y)*(p3.X-p1.X)
	d = -a*p1.X - b*p1.Y - c*p1.Z

	return Plane3D{
		a,
		b,
		c,
		d,
	}
}

// GetNumberOfIterations computes the number of required RANSAC iterations
// both inputs between 0 and 1 (can use 0.99 and 0.5)
func GetNumberOfIterations(confidence float64, percentageOfPointsOnPlane float64) int {
	op1 := math.Log10(1 - confidence)
	op2 := math.Log10(1 - math.Pow(percentageOfPointsOnPlane, 3))
	numIterations := math.Round(op1 / op2)
	return int(numIterations)
}

// GetSupport computes the support of a plane in a set of points
// can use eps 0.5
func GetSupport(plane Plane3D, points []Point3D, eps float64) Plane3DwSupport {
	var support int
	support = 0
	for i := 0; i < len(points); i++ {
		//distance between plane and 3D point at index i
		dist := (math.Abs(plane.A*points[i].X + plane.B*points[i].Y + plane.C*points[i].Z + plane.D)) / (math.Sqrt(plane.A*plane.A + plane.B*plane.B + plane.C*plane.C))
		//if distance is less than eps value, increase support value
		if dist < eps {
			support++
		}
	}

	return Plane3DwSupport{
		plane,
		support,
	}
}

// GetSupportingPoints extracts the points that support the given plane and returns them as a slice of points
func GetSupportingPoints(plane Plane3D, points []Point3D, eps float64) []Point3D {
	var supportingPoints []Point3D
	for i := 0; i < len(points); i++ {
		//distance between plane and 3D point at index i
		dist := (math.Abs(plane.A*points[i].X + plane.B*points[i].Y + plane.C*points[i].Z + plane.D)) / (math.Sqrt(plane.A*plane.A + plane.B*plane.B + plane.C*plane.C))
		//if distance is less than eps value, add supporting point to the slice
		if dist < eps {
			supportingPoints = append(supportingPoints, points[i])
		}
	}
	return supportingPoints
}

// RemovePlane creates a new slice of points in which all points belonging to the plane have been removed
func RemovePlane(plane Plane3D, points []Point3D, eps float64) []Point3D {
	var removedPlane []Point3D
	for i := 0; i < len(points); i++ {
		//distance between plane and 3D point at index i
		dist := (math.Abs(plane.A*points[i].X + plane.B*points[i].Y + plane.C*points[i].Z + plane.D)) / (math.Sqrt(plane.A*plane.A + plane.B*plane.B + plane.C*plane.C))
		//if distance is equal or more than eps value, a point doesn't belong to the plane and added to the slice
		if dist >= eps {
			removedPlane = append(removedPlane, points[i])
		}
	}
	return removedPlane
}

func pointGenerator(input []Point3D, stop chan struct{}) <-chan Point3D {
	result := make(chan Point3D)
	go func() {
		defer close(result)
		for {
			select {
			case <-stop:
				return
			default:
			}
			n := rand.Intn(len(input))
			result <- input[n]
		}
	}()
	return result
}

func tripleGenerator(input <-chan Point3D) <-chan [3]Point3D {
	result := make(chan [3]Point3D)
	go func() {
		defer close(result)
		var output [3]Point3D
		var n int
		for pt := range input {
			output[n] = pt
			n++
			if n == 3 {
				result <- output
				n = 0
			}
		}
	}()
	return result
}

func takeN(n int, stop chan struct{}, input <-chan [3]Point3D) <-chan [3]Point3D {
	result := make(chan [3]Point3D)
	go func() {
		defer close(result)
		var cnt int
		for pt := range input {
			cnt++
			if cnt == n {
				close(stop)
				continue
			}
			if cnt < n {
				result <- pt
			}
		}
	}()
	return result
}

func planeEstimator(input <-chan [3]Point3D) <-chan Plane3D {
	result := make(chan Plane3D)
	go func() {
		defer close(result)
		for pt := range input {
			plane := GetPlane(pt[:])
			result <- plane
		}
	}()
	return result
}

func findSupportingPoints(points []Point3D, eps float64, input <-chan Plane3D) <-chan Plane3DwSupport {
	result := make(chan Plane3DwSupport)
	go func() {
		defer close(result)
		for plane := range input {
			support := GetSupport(plane, points, eps)
			result <- support
		}
	}()
	return result
}

func fanIn(input []<-chan Plane3DwSupport) <-chan Plane3DwSupport {
	result := make(chan Plane3DwSupport)

	go func() {
		defer close(result)
		wg := sync.WaitGroup{}
		for _, inp := range input {
			inp := inp
			wg.Add(1)
			go func() {
				defer wg.Done()
				for i := range inp {
					result <- i
				}
			}()
		}
		wg.Wait()
	}()

	return result
}

func main() {

	//runtime.GOMAXPROCS(3)
	start := time.Now()

	argFile := os.Args[1]
	inputFile := ReadXYZ(argFile)

	var confidence float64
	confidence, _ = strconv.ParseFloat(os.Args[2], 64)
	var percentage float64
	percentage, _ = strconv.ParseFloat(os.Args[3], 64)
	numIterations := GetNumberOfIterations(confidence, percentage)
	var eps float64
	eps, _ = strconv.ParseFloat(os.Args[4], 64)

	stop := make(chan struct{})
	points := pointGenerator(inputFile, stop)
	triples := tripleGenerator(points)
	taken := takeN(numIterations, stop, triples)
	planes := planeEstimator(taken)
	FanOutN := 1
	supportPointsCh := make([]<-chan Plane3DwSupport, 0, FanOutN)
	for i := 0; i < FanOutN; i++ {
		supportCh := findSupportingPoints(inputFile, eps, planes)
		supportPointsCh = append(supportPointsCh, supportCh)
	}
	supportCh := fanIn(supportPointsCh)
	var lastPlane *Plane3DwSupport
	for plane := range supportCh {
		// plane has better support than last plane, or lastPlane==nil
		if lastPlane == nil || lastPlane.SupportSize < plane.SupportSize {
			plane := plane
			lastPlane = &plane
		}
	}

	output := GetSupportingPoints(lastPlane.Plane3D, inputFile, eps)
	pointsToRemove := RemovePlane(lastPlane.Plane3D, inputFile, eps)
	//fmt.Println(GetSupportingPoints(lastPlane.Plane3D, inputFile, eps))
	//fmt.Println(lastPlane)

	duration := time.Since(start)

	fmt.Println(duration)

	SaveXYZ("PointCloud3_p3", output)
	SaveXYZ("PointCloud3_p0", pointsToRemove)

}
