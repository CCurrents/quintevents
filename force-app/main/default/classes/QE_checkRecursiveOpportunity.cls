public class QE_checkRecursiveOpportunity{
    public static boolean run = true;
    private static boolean runOne = true;
    private static boolean runTwo = true;
    private static boolean runThree = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
   
    
    public static boolean runTwo(){
        if(runOne){
            runOne =false;
            return true;
        }else{
            return runOne ;
        }
    }
    
    public static boolean runThree(){
        if(runTwo){
            runTwo=false;
            return true;
        }else{
            return runTwo;
        }
    } 
    
    public static boolean runFour(){
    if(runThree){
            runThree=false;
            return true;
        }else{
            return runThree;
        }
    
    }
}