/**
 * The class <b>Point3D</b> is the class that implements 3D point. 
 */


public class Point3D
{
    private double x;
    private double y;
    private double z;
   
    public Point3D(double x, double y, double z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public double getX() { return x; }
    public double getY() { return y; }
    public double getZ() { return z; }

    public String toString() 
    {
        String str = String.valueOf(x) + "\t" + String.valueOf(y) + "\t" +String.valueOf(z); 

        return str;
    }
}