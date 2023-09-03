/**
 * The class <b>Plane3D</b> is the class that implements 3D plane. 
 */

import java.security.InvalidParameterException;

public class Plane3D {
    
    private final double TOLERANCE = 0.001;

    double a, b, c, d; 

    double iTerm;

    Vector3D baseline; 

    /**
     * constructor which takes in 3 points.
     */
    
    public Plane3D(Point3D p1, Point3D p2, Point3D p3)
    {
        baseline = Vector3D.crossProduct(new Vector3D(p1, p2), new Vector3D(p1, p3));

        if (baseline.magnitude() < TOLERANCE)
            throw new InvalidParameterException("Specified points do not define a valid plane.");

        iTerm = -(baseline.getX() * p1.getX() + baseline.getY() * p1.getY() + baseline.getZ() * p1.getZ());
    }

    /**
     * constructor which takes in a,b,c,d values.
     */

    public Plane3D(double a, double b, double c, double d)
    {
        
    }

    /**
     * returns the distance
     * 
     * @param pt
     * @return distance.
     */

    public double distance(Point3D pt)
    {        
        return Math.abs(baseline.getX() * pt.getX() + baseline.getY() * pt.getY() + baseline.getZ() * pt.getZ() + iTerm);
    }

    /**
     * returns if distance within tolerance
     * 
     * @param pt
     * @return boolean.
     */

    public boolean contains(Point3D pt) { return distance(pt) < TOLERANCE; }

}
