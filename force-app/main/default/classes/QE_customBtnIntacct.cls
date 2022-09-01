global class QE_customBtnIntacct{
    webservice static void callIntacct(String oppId) {
        QE_Intacct_FutureCallout.sendDataIntacct(oppId);
    }
}