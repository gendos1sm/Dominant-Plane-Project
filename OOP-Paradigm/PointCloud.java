import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

public class PointCloud {
        
    List<Point3D> points;
    String filename;

    /**
     * default constructor
     */
     
    PointCloud()
    {
        points = new ArrayList<Point3D>();
    }

    /**
     * constructor that takes ptList as input
     */
        
    PointCloud(ArrayList<Point3D> ptList)
    {
        points = ptList;
    }

    /**
     * constructor for a filename
     */

    PointCloud(String filename)throws IOException
    {
        this.filename = filename;

        points = new ArrayList<Point3D>();

        File file = new File(this.filename);

        BufferedReader br = new BufferedReader(new FileReader(file));

        // Read in and parse each line of the file and store data in the points list
        String line;
        String [] coords = new String[3];
        int i = 0;
        while ((line = br.readLine()) != null)
        {
            if (i > 0)
            {
                coords = line.split("\t");
                points.add(new Point3D(Double.parseDouble(coords[0]), Double.parseDouble(coords[1]), Double.parseDouble(coords[2])));
            }

            i++;
        }

        br.close();
    }

    public void addPoint(Point3D pt)
    {
        points.add(pt);
    }

    String getFileName() { return filename; }

    Point3D getPoint()
    {
        Random random = new Random();

        int i = random.nextInt(points.size());

        return points.get(i);
    }
        
    List<Point3D> getPointList() { return points; }

    public void save(String filename) throws IOException
    {       
        FileWriter fWriter = new FileWriter(filename);
      
        // Write the header to the file
        String line = "x" + "\t" + "y" + "\t" + "z\n";
        fWriter.write(line);
   
        for (int i = 0; i < points.size(); i++)
        {
            Point3D p = points.get(i);
            
            line = p.toString() + "\n";

            fWriter.write(line);
        }

        fWriter.close();
    }

    Iterator<Point3D> iterator()
    {        
        return points.iterator();
    }
}
