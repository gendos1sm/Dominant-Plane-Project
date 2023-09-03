import java.io.IOException;
import java.security.InvalidParameterException;
import java.util.ArrayList;

import java.util.Iterator;

/**
 * The class <b>PlaneRansac</b> is the class that implements ransac algorithm. 
 */

public class PlaneRANSAC {

    Plane3D bestPlane;

    double eps;

    PointCloud pc;

    int bestSupport;

    ArrayList<Point3D> bestSupportList, supportList;

    /**
     * constructor which takes in pc PointCloud.
     */

    public PlaneRANSAC(PointCloud pc)
    {
        this.pc = pc;

        supportList = new ArrayList<Point3D>();
    }

    public void setEps(double eps)
    {
        this.eps = eps;
    }

    public double getEps() { return eps; }

    /**
     * returns the number of iterations
     * 
     * @param confidence
     * @param percentageOfPointsOnPlane
     * @return numIterations
     */
   
    public int getNumberOfIterations(double confidence, double percentageOfPointsOnPlane)
    {       
        double op1 = Math.log(1.0 - confidence);

        double op2 = Math.log(1 - Math.pow(percentageOfPointsOnPlane, 3));

        long numIterations = Math.round(op1/op2);
       
        return (int) numIterations;
    }

    /**
     * runs Ransac algorithm
     * 
     * @param numberOfIterations
     * @param filename
     */

    public void run(int numberOfIterations, String filename) throws IOException
    {
        bestSupport = 0;  bestSupportList = new ArrayList<Point3D>();
      
        for (int i = 0; i < numberOfIterations; i++)
        {         
            supportList.clear();
            
            Point3D one = pc.getPoint(), two = pc.getPoint(), three = pc.getPoint();

            Plane3D plane = null;
            try
            {
                 plane = new Plane3D(one, two, three);
            }
            catch (InvalidParameterException ipe)
            {
                i--;
                continue;
            }

            Iterator<Point3D> iter = pc.iterator();

            while(iter.hasNext())
            {
                Point3D pt = iter.next();

                double dist = plane.distance(pt);

                if (dist < eps)
                {   
                  supportList.add(pt);                
                }
            }

            if (supportList.size() > bestSupport)
            {
                bestPlane = plane;
                bestSupport = supportList.size();

                bestSupportList.clear();
                
                for (var pt : supportList)
                {
                    Point3D newPt = new Point3D(pt.getX(), pt.getY(), pt.getZ());
    
                    bestSupportList.add(newPt);
                }
             
                supportList.clear();
            }
        }

        PointCloud newPtCloud = new PointCloud(bestSupportList);
        
        newPtCloud.save(filename);
   }
}
