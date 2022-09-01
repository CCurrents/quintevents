@isTest public class GenerateSlackTokenTest {
    
    @isTest static void testRun1(){
        GenerateSlackToken.generateToken();
        String code = '457678512738.1202028572880.894208179661eec84858c49baf340f552c048bb2cf1dd1954c0ee8d93c7d510d';
        GenerateSlackToken.getaccesstoken(code);
    }
}