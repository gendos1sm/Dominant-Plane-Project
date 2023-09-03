import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException {
        
        for (int i = 0; i < 3; i++)
        {
            String filename = String.format("PointCloud%d.xyz", i + 1);

            PointCloud pc = new PointCloud(filename);
    
            PlaneRANSAC ransac = new PlaneRANSAC(pc);
            ransac.setEps(1.0);
    
            int iterations = ransac.getNumberOfIterations(0.99, .20);
            
            for (int j = 0; j < 3; j++)
            {
                String fileName = filename.substring(0, 11) + "_p" + (j + 1) + ".xyz";

                ransac.run(iterations, fileName);
            }
        }
    }
}
