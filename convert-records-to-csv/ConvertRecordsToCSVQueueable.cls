public class GenerateCSVContentQueueable implements Queueable {
    private List<SObject> objectList;
    private List<String> fieldsList;
    private List<String> linkedRecordIds;
    private String documentTitle;
    private String documentShareType;
    private String documentVisibility;

    public GenerateCSVContentQueueable(List<SObject> objectList, List<String> fieldsList, List<String> linkedRecordIds, String documentTitle, String documentShareType, String documentVisibility) {
        this.objectList = objectList;
        this.fieldsList = fieldsList;
        this.linkedRecordIds = linkedRecordIds;
        this.documentTitle = documentTitle;
        this.documentShareType = documentShareType;
        this.documentVisibility = documentVisibility;
    }

    public void execute(QueueableContext context) {
        String content = GenerateSObjectCSV.generateCSVContent(objectList, fieldsList);  
        GenerateSObjectCSV.Outputs returnVal = GenerateSObjectCSV.generateDocument(linkedRecordIds, documentTitle, documentShareType, documentVisibility, content) ;
        // Generate platform event
        // CSV_Document__e documentCompleteEvent = new CSV_Document__e();
        // documentCompleteEvent.ContentDocumentId = returnVal.contentDocumentId;
        // documentCompleteEvent.ContentDocumentLinks = returnVal.contentDocumentLinks;
        // documentCompleteEvent.ContentVersionId = returnVal.contentVersionId;

        // List<Database.SaveResult> results = EventBus.publish(new List<CSV_Document__e>{documentCompleteEvent});
        // for (Database.SaveResult result: results) {
        //     if (!result.isSuccess()) {
        //         // potentially throw and error here?
        //         System.debug('CSV document event publication failed.');
        //     }
        // }
    }
}