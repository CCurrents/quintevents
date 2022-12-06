/**
 * Created by joshlequire1 on 11/17/22.
 */

public with sharing class CreateConsentTransactionInvocable {

    @InvocableMethod(Label='ParseStringToList' Description='Takes a string with values separated by semi-colons and creates a list of Ids from it.' Category='String')
    public static List<List<Pricebook2>> parseStringToIds(List<String> inputStrings) {

        if (inputStrings != null) {
            List<List<Pricebook2>> returnList = new List<List<Pricebook2>>();
            List<String> idValues = inputStrings[0].split(';');
            List<Pricebook2> pbIDs = new List<Pricebook2>();
            for (String idv : idValues) {
                Pricebook2 newPB = new Pricebook2();
                newPB.Id = Id.valueOf(idv);
                pbIDs.add(newPB);
            }

            returnList.add(pbIDs);

            return returnList;
        }

        else {
            return null;
        }

    }

}