public abstract with sharing class OCRStrategy {

    private Object stream;

    protected Map<Integer, OCRLine> ocrByIndex;
    protected Map<String, Integer> indexByText;
    protected OCRLine[] ocrs;

    public OCRStrategy() {

        ocrByIndex = new Map<Integer, OCRLine>();
        indexByText = new Map<String, Integer>();
    }

    public abstract Schindler_Invoice_History__c createInvoice();

    public void setStream(Object stream) {

        this.stream = stream;
    }

    protected void loadMaps() {

        Map<String, Object> page = (Map<String, Object>) stream;

        Object[] lines = (Object[]) page.get('Lines');

        String jsonLines = JSON.serialize(lines);

        OCRLine[] ocrLines = (OCRLine[]) JSON.deserialize(jsonLines, List<OCRLine>.class);

        Integer index = 0;

        for (OCRLine ocrLine :ocrLines) {

            String lineText = ocrLine.getLine();

            if (indexByText.containsKey(lineText)) {
                lineText = lineText + '-' + String.valueOf(index);
            }

            ocrByIndex.put(index, ocrLine);
            indexByText.put(lineText, index);
            index ++;
        }

        System.debug(JSON.serializePretty(ocrByIndex));
    }

}