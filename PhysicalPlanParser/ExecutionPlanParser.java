/*
Execution plan Parser
Zacharia Fadika
Intel corporation - DSS team 

*/


import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.LinkedList;
import java.util.LinkedHashMap;
import java.util.*;

public class ExecutionPlanParser {

	static HashMap<String, Integer> ExecOpHashMap = new HashMap<>();
	static HashMap<String, Integer> DataTypeHashMap = new HashMap<>();
	static HashMap<String, Integer> ExpressionHashMap = new HashMap<>();

	public static void main(String[] args) {

		if (args.length != 1) 
		{
			System.out.println();
			System.out.println("Error: Filename missing");
			System.out.println();
			System.out.println("Usage: java EParser filename.jason");
			System.out.println();
			System.exit(0);			
		}

		// This will kill execution if required files are missing
		RequiredfilesExistCheck();

		BufferedReader reader;

		try {
			reader = new BufferedReader(new FileReader(args[0]));
			String inputline = reader.readLine();

			while (inputline != null) {


				String[] outputlines = inputline.split(",");
				for (String outputline : outputlines) 
				{
					outputline=outputline+",\n";

					//search line for EXec
				
					ExecOpSearch(outputline);
					//search line for dataType
					DataTypeSearch(outputline);
					//search line for name
					ExpressionFuncSearch(outputline);
				}
				// read next line
				inputline = reader.readLine();
			}

			reader.close();
		} catch (IOException e) {
			e.printStackTrace();
		}



	ExecOpReport();
        DataTypeReport();
        ExpressionFuncReport();


	}

	private static void ExecOpSearch(String line)
	{                
		String ExecOperator="";
		if (line.contains("Exec\""))
		{
			ExecOperator = line.substring(line.lastIndexOf​(".")+1,line.lastIndexOf​​​("Exec\""));
			if (ExecOpHashMap.containsKey(ExecOperator))
			{
				
				ExecOpHashMap.computeIfPresent(ExecOperator,(key, val) -> val + 1);	
			}	
			else
			{
				ExecOpHashMap.put(ExecOperator,1);
			}

		}
	}

	private static void DataTypeSearch(String line)
        {

		String DataType="";

                if (line.contains("dataType"))
                {
                        DataType = line.substring((line.lastIndexOf​(":"))+2,line.lastIndexOf​​("\""));
                        if (DataTypeHashMap.containsKey(DataType))
                        {
                                DataTypeHashMap.computeIfPresent(DataType,(key, val) -> val + 1);     
                        }       
                        else
                        {
                                DataTypeHashMap.put(DataType,1);
                        }

                }

        }

	private static void ExpressionFuncSearch(String line)
        {
		String Expression="";

                if (line.contains(".expressions.") )
                {
                        Expression = line.substring((line.lastIndexOf​(".expressions."))+13,line.lastIndexOf​​("\""));
			if (Isexpression(Expression))
			{
                        	if (ExpressionHashMap.containsKey(Expression))
                        	{
                                	ExpressionHashMap.computeIfPresent(Expression,(key, val) -> val + 1);     
                        	}       
                        	else
                        	{
                                	ExpressionHashMap.put(Expression,1);
                        	}
			}

                }
        }


	private static void ExecOpReport()
        {
		int ValueSum=0;
		for (int totalValue : ExecOpHashMap.values()) 
		{
    			ValueSum += totalValue;
		}
		HashMap<String, Integer> NewExecOpHashMap = sortIntValue(ExecOpHashMap);
		System.out.println("");
		System.out.println("-------------------");
                System.out.println("Execution Operators");
		System.out.println("-------------------");
		String key="";
		String gluten_supported = "";
		for( HashMap.Entry<String, Integer> entry : NewExecOpHashMap.entrySet() )
		{
			key=entry.getKey();
			gluten_supported="NOT GLUTEN SUPPORTED";
			if (IsOperatorGluttenSupported(key))
			{
				gluten_supported = "Gluten Supported";
			}
    			System.out.println( key + "   " + (((float)entry.getValue()/(float)ValueSum)*100)+" %"+"       Count = "+entry.getValue()+"   "+gluten_supported );
		}

        }


	private static void DataTypeReport()
        {
		int ValueSum=0;
                for (int totalValue : DataTypeHashMap.values()) 
                {
                        ValueSum += totalValue;
                }
		HashMap<String, Integer> NewDataTypeHashMap = sortIntValue(DataTypeHashMap);
		System.out.println("");
		System.out.println("----------");
                System.out.println("Data Types");
                System.out.println("----------");
                for( HashMap.Entry<String, Integer> entry : NewDataTypeHashMap.entrySet() )
                {
                        System.out.println( entry.getKey() + "   " + (((float)entry.getValue()/(float)ValueSum)*100)+" %"+"       Count = "+entry.getValue() );
                }

        }

	private static void ExpressionFuncReport()
        {


		int ValueSum=0;
                for (int totalValue : ExpressionHashMap.values()) 
                {
                        ValueSum += totalValue;
                }
                HashMap<String, Integer> NewExpressionHashMap = sortIntValue(ExpressionHashMap);
		System.out.println("");
                System.out.println("-----------");
                System.out.println("Expressions");
                System.out.println("-----------");
		String key="";
		String gluten_supported="";
                for( HashMap.Entry<String, Integer> entry : NewExpressionHashMap.entrySet() )
                {
			key = entry.getKey();
			gluten_supported="NOT GLUTEN SUPPORTED";
			if (IsexpressionGluttenSupported(key))
			{
				gluten_supported = "Gluten supported";
			}
				
                        System.out.println( key + "   " + (((float)entry.getValue()/(float)ValueSum)*100)+" %"+"       Count = "+entry.getValue()+"   "+gluten_supported );
                }

		System.out.println("");

        }


	public static HashMap<String, Integer> sortIntValue(HashMap<String, Integer> hashm)
    	{
        	// List from HashMap
        	List<Map.Entry<String, Integer> > list = new LinkedList<Map.Entry<String, Integer> >(hashm.entrySet());
 
        	// Sort 
        	Collections.sort(list, new Comparator<Map.Entry<String, Integer> >() {
            	public int compare(Map.Entry<String, Integer> elemA, Map.Entry<String, Integer> elemB)
            	{
			return (elemB.getValue()).compareTo(elemA.getValue());
			//return (elemA.getValue()).compareTo(elemB.getValue()); // descending order
            	}
        	});
         
        	// put data from sorted list to hashmap
        	HashMap<String, Integer> sortedMAP = new LinkedHashMap<String, Integer>();
        	for (Map.Entry<String, Integer> varA : list) 
		{
            		sortedMAP.put(varA.getKey(), varA.getValue());
        	}
        	return sortedMAP;
    	}

	private static boolean Isexpression(String expr)
        {
		boolean answer = false;
		BufferedReader reader;

                try {
                        reader = new BufferedReader(new FileReader("TotalExpression.List"));
                        String inputline = reader.readLine();

                        while (inputline != null) {
				inputline = inputline.trim();
				
				if (inputline.equalsIgnoreCase(expr))
				{
					answer = true;
					break;
				}

                                // read next line
                                inputline = reader.readLine();
                        }

                        reader.close();
                } catch (IOException e) {
                        e.printStackTrace();
                }


		return answer;

        }

	private static boolean IsexpressionGluttenSupported(String expr)
        {
                boolean answer = false;
                BufferedReader reader;

                try {
                        reader = new BufferedReader(new FileReader("GluttenSupportedExpression.List"));
                        String inputline = reader.readLine();

                        while (inputline != null) {
                                inputline = inputline.trim();

                                if (inputline.equalsIgnoreCase(expr))
                                {
                                        answer = true;
                                        break;
                                }

                                // read next line
                                inputline = reader.readLine();
                        }

                        reader.close();
                } catch (IOException e) {
                        e.printStackTrace();
                }


                return answer;

        }

	private static boolean IsOperatorGluttenSupported(String expr)
        {
		boolean answer = false;
                BufferedReader reader;

                try {
                        reader = new BufferedReader(new FileReader("GluttenSupportedOperator.List"));
                        String inputline = reader.readLine();

                        while (inputline != null) {
                                inputline = inputline.trim();

                                if (inputline.equalsIgnoreCase(expr))
                                {
                                        answer = true;
                                        break;
                                }

                                // read next line
                                inputline = reader.readLine();
                        }

                        reader.close();
                } catch (IOException e) {
                        e.printStackTrace();
                }


                return answer;

        }

	private static void RequiredfilesExistCheck()
        {


		File expressionList = new File("TotalExpression.List");
		File glutenOperatorList = new File("GluttenSupportedOperator.List");
		File gluttenExpressionList = new File("GluttenSupportedExpression.List");
 
                if (!expressionList.exists())
		{
 
			System.out.println("Error: The file TotalExpression.List is missing the program cannot continue");
			System.exit(0);
		}

		if (!glutenOperatorList.exists())
                {
 
                        System.out.println("Error: The file GluttenSupportedOperator.List is missing the program cannot continue");
                        System.exit(0);
                }
		if (!gluttenExpressionList.exists())
                {
 
                        System.out.println("Error: The file GluttenSupportedExpression.List is missing the program cannot continue");
                        System.exit(0);
                }

	}

}
