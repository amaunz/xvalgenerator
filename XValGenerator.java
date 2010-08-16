import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.Random;
import java.util.Vector;

import com.sun.org.apache.xalan.internal.xsltc.cmdline.getopt.GetOpt;

public class XValGenerator
{
    public static boolean VERBOSE = true;

    public static final long RANDOM_SEED = 59;

    public static void main(String args[])
    {
// args = new String[] { "-s",
//        "/home/martin/data/cpdb/hamster_carcinogenicity/data/hamster_carcinogenicity.smi"
//        ,
//        "-t",
// "/home/martin/data/cpdb/hamster_carcinogenicity/data/hamster_carcinogenicity.class",
//        "-o",
// "/home/martin/tmp/xout", "-n", "10" };

        String usage = "performs x-validation split on smile and class files (as used by lazar).\n" + "usage:\n"
                       + "-s <string>\tsmiles file\n" + "-t <string>\tclass file\n"
                       + "-o <string>\tbase output filename (string.X.train/test)\n" + "-n <number>\tnum folds\n" + "-b\tbalanced\n"; 

        GetOpt opt = new GetOpt(args, "s:t:o:n:b");

        File smiFile = null;
        File classFile = null;
        File outFile = null;
        int numFolds = -1;
        boolean balanced = false;

        try
        {
            int o = -1;
            while ((o = opt.getNextOption()) != -1)
            {
                if (o == 's')
                    smiFile = new File(opt.getOptionArg());
                else if (o == 'o')
                    outFile = new File(opt.getOptionArg());
                else if (o == 't')
                    classFile = new File(opt.getOptionArg());
                else if (o == 'n')
                    numFolds = Integer.parseInt(opt.getOptionArg());
                else if (o == 'b')
                    balanced = true;
            }

            if (smiFile == null || !smiFile.exists() || classFile == null ||
                    !classFile.exists() || outFile == null
                    || numFolds == -1)
                throw new IllegalStateException("illegal params");

        }
        catch (Exception e)
        {
            System.err.println(e.getMessage());
            System.err.println(usage);
            System.exit(1);
        }

        new XValGenerator(smiFile, classFile, outFile, numFolds, balanced);
    }

    public XValGenerator(File smiFile, File classFile, File outFile, int numFolds, boolean balanced)
    {
        try
        {
            Vector<String> smiFileContent = readFile(smiFile);
            Vector<String> classFileContent = readFile(classFile);

            if (smiFileContent.size() != classFileContent.size())
                throw new IllegalStateException("input files have different line count");

            if (VERBOSE)
                System.out.println("num components: " + smiFileContent.size());

            File classTrainFiles[] = new File[numFolds];
            File classTestFiles[] = new File[numFolds];
            for (int i = 0; i < numFolds; i++)
            {
                String path = outFile.getPath(); if (numFolds>1) path += "." + i; 
                classTrainFiles[i] = new File(path + ".train.class");
                if (classTrainFiles[i].exists())
                    throw new IllegalStateException("outfile already exists");
                if (numFolds>1) path += ".test";
                classTestFiles[i] = new File(path + ".class");
                if (classTestFiles[i].exists())
                    throw new IllegalStateException("outfile already exists");
            }

            File smiTrainFiles[] = new File[numFolds];
            File smiTestFiles[] = new File[numFolds];
            for (int i = 0; i < numFolds; i++)
            {
                String path = outFile.getPath(); if (numFolds>1) path += "." + i; 
                smiTrainFiles[i] = new File(path + ".train.smi");
                if (smiTrainFiles[i].exists())
                    throw new IllegalStateException("outfile already exists");
                if (numFolds>1) path += ".test";
                smiTestFiles[i] = new File(path + ".smi");
                if (smiTestFiles[i].exists())
                    throw new IllegalStateException("outfile already exists");
            }

            int ordering[] = new int[smiFileContent.size()];
            for (int i = 0; i < ordering.length; i++)
                ordering[i] = i;
            Random r = new Random(RANDOM_SEED);
            for (int i = 0; i < ordering.length; i++)
            {
                int rand_i = r.nextInt(ordering.length);
                int tmp = ordering[i];
                ordering[i] = ordering[rand_i];
                ordering[rand_i] = tmp;
            }

            int actives=0;
            Vector<String> bck_smi = new Vector();
            Vector<String> bck_cls = new Vector();
            for (int i = 0; i < smiFileContent.size(); i++)
            {
                int x = i % numFolds;

                for (int j = 0; j < numFolds; j++)
                {
                    boolean test = j == x;

// if (VERBOSE)
// System.out.print((test ? "test  " : "train ") + (j + 1) + " " +
                    smiFileContent.get(ordering[i]);

                    if (!balanced) {
                        FileWriter w = new FileWriter(test ? classTestFiles[j] : classTrainFiles[j], true);
                        w.append(classFileContent.get(ordering[i]));
                        w.close();

                        w = new FileWriter(test ? smiTestFiles[j] : smiTrainFiles[j], true);
                        w.append(smiFileContent.get(ordering[i]));
                        w.close();
                    }
                    else {
                        char act = classFileContent.get(ordering[i]).trim().charAt(classFileContent.get(ordering[i]).trim().length()-1);
                        if (act == '1') actives+=1;
                        if (act == '0' && actives==0) { bck_smi.add(classFileContent.get(ordering[i])); bck_cls.add(classFileContent.get(ordering[i])); }
                        if (act == '1' || actives>0) {
                            FileWriter w = new FileWriter(test ? classTestFiles[j] : classTrainFiles[j], true);
                            w.append(classFileContent.get(ordering[i]));
                            w.close();

                            w = new FileWriter(test ? smiTestFiles[j] : smiTrainFiles[j], true);
                            w.append(smiFileContent.get(ordering[i]));
                            w.close();

                            /*
                             * AM: 
                            if (i == smiFileContent.size()-1) {
                                for (int k=0; k<bck_smi.size() && actives>0; k++) {
                                    w = new FileWriter(test ? classTestFiles[j] : classTrainFiles[j], true);
                                    w.append(bck_cls.elementAt(k));
                                    w.close();

                                    w = new FileWriter(test ? smiTestFiles[j] : smiTrainFiles[j], true);
                                    w.append(bck_smi.elementAt(k));
                                    w.close();

                                    actives-=1;
                                }
                            }
                            */

                            if (act == '0' && actives>0) actives -= 1;
                        }
                    }

                }
            }

        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    public Vector<String> readFile(File f) throws Exception
    {
        BufferedReader r = new BufferedReader(new FileReader(f));
        String s;
        Vector<String> res = new Vector<String>();

        while ((s = r.readLine()) != null)
        {
            res.add(s + "\n");
        }
        r.close();

        return res;
    }
}

