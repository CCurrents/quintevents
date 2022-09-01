public without sharing class RunAsAdminUtility {
    public static void deleteContentDistibution(){
		delete [select id,DistributionPublicUrl from ContentDistribution];
    }
}