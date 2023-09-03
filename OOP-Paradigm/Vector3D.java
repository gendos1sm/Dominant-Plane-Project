/**
 * The class <b>Vector3D</b> is the class that implements 3D vector. 
 */

public class Vector3D {
    
    double x, y, z; 

    public Vector3D(Point3D p1, Point3D p2)
    {
        x = p2.getX() - p1.getX();
        y = p2.getY() - p1.getY(); 
        z = p2.getZ() - p1.getZ();
    }
  
    public Vector3D(double x, double y, double z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public double getX() { return x; }
    public double getY() { return y; }
    public double getZ() { return z; }

    public double magnitude()
    {
        double m = Math.pow(x, 2) + Math.pow(y, 2) + Math.pow(z, 2);

        double mag = Math.sqrt(m);
        
        return mag;
    } 

    public static Vector3D crossProduct(Vector3D left, Vector3D right)
    {
        double tmpX = 0, tmpY = 0, tmpZ = 0;
        
        tmpX = left.y * right.z - left.z * right.y;
        tmpY = left.z * right.x - left.x * right.z;
        tmpZ = left.x * right.y - left.y * right.x;

        return new Vector3D(tmpX, tmpY, tmpZ);
    }

    public static double dotProduct(Vector3D left, Vector3D right)
    {
        return left.x * right.x + left.y * right.y + left.z * right.z;
    }

}