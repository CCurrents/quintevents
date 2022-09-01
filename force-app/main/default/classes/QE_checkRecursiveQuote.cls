public class QE_checkRecursiveQuote{
    private static boolean run = true;
    private static boolean runOne = true;
    private static boolean runTwo = true;
    public static Set<Id> setOfIds = new Set<Id>();
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
    
    /* public static boolean runThree(){
        if(runTwo){
            runTwo=false;
            return true;
        }else{
            return runTwo;
        }
    }
    */
}