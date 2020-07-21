public with sharing class OCRStrategyThyssen extends OCRStrategy {

    public OCRStrategyThyssen() {
        super();
    }

    public override Schindler_Invoice_History__c createInvoice() {

        loadMaps();

        Schindler_Invoice_History__c result = new Schindler_Invoice_History__c();

        Integer index = null;
        Integer index2 = null;
        Integer boundaryIndex = 0;

        // Invoice Date
        index = indexByText.get('INVOICE DATE:');
        if (index != null) {
            String invoiceDate = ocrByIndex.get(index + 1).getLine();
            try {
                result.Invoice_Date__c = Date.parse(invoiceDate);
            }
            catch (TypeException ex) {
                result.Invoice_Date__c = null;
            }
        }

        // Order Number
        index = indexByText.get('SR #:');
        if (index != null) {
            result.Order_No__c = ocrByIndex.get(index + 1).getLine();
        }

        // Invoice Number
        index = indexByText.get('INVOICE #:');
        if (index != null) {
            result.Name = ocrByIndex.get(index + 1).getLine();
        }

        // Contract Number
        index = indexByText.get('CUSTOMER #:');
        if (index != null) {
            result.Contract__c = ocrByIndex.get(index + 1).getLine();
        }

        // Days to Pay
        index = indexByText.get('TERMS:');
        if (index != null) {
            result.Days_To_Pay__c = ocrByIndex.get(index + 1).getLine();
        }

        // Total Due
        index = indexByText.get('TOTAL DUE:');
        if (index != null) {

            String totalInvoiceAmount = ocrByIndex.get(index + 1).getLine();

            if (totalInvoiceAmount != null) {
                totalInvoiceAmount = totalInvoiceAmount.remove('$');
                try {
                    result.Invoice_Total__c = Decimal.valueOf(totalInvoiceAmount);
                }
                catch (TypeException ex) {
                    result.Invoice_Total__c = null;
                }
            }
        }

        // Bill To
        index = indexByText.get('BILL TO:');
        if (index != null) {

            Set<String> billAddresses = new Set<String>();

            for (Integer i = index; i < index + 8; i++) {

                String line = ocrByIndex.get(index + 1).getLine();

                if (line.containsIgnoreCase('Reported By')) {
                    break;
                }
                else if (line.containsIgnoreCase('SHIP TO')) {
                    // Ignore Ship Title
                    continue;
                }
                else {
                    line = line.trim();
                    billAddresses.add(line);
                }
            }

            result.Bill_To__c = String.join(new List<String>(billAddresses), '\n');
        }

        // Service Date - Tricky One
        index = indexByText.get('AMOUNT');
        if (index != null) {
            // We need to iterate to find the Date = 10 lines max distance
            for (Integer i = index; i < index + 10; i++) {

                String potentialDate = ocrByIndex.get(i + 1).getLine();
                potentialDate = potentialDate.trim();

                // Evaluate date format
                if ((potentialDate.length() == 10) && (potentialDate.indexOf('/') == 2) && (potentialDate.lastIndexOf('/') == 5)) {
                    try {
                        result.Date_of_Service__c = Date.parse(potentialDate);
                        break;
                    }
                    catch (TypeException ex) {
                        result.Date_of_Service__c = null;
                    }
                }
            }
        }

        // Description
        result.Description__c = getDescription();

        // Subtotal
        index = indexByText.get('PLEASE PAY THIS AMOUNT');
        if (index != null) {
            String subTotal = ocrByIndex.get(index + 1).getLine();

            if (subTotal != null) {
                subTotal = subTotal.remove('$');
                try {
                    result.Sub_Total__c = Decimal.valueOf(subTotal);
                }
                catch (TypeException ex) {
                    result.Sub_Total__c = null;
                }
            }
        }

        // Tax
        index = indexByText.get('PLEASE PAY THIS AMOUNT');
        if (index != null) {
            String tax = ocrByIndex.get(index + 2).getLine();

            if (tax != null) {
                tax = tax.remove('$');
                try {
                    result.Tax__c = Decimal.valueOf(tax);
                }
                catch (TypeException ex) {
                    result.Tax__c = null;
                }
            }
        }

        return result;
    }

    private String getDescription() {

        Integer index = null;

        // Find Resolution Summary
        for (String key :indexByText.keySet()) {

            if (key.containsIgnoreCase('Resolution Summary')) {
                index = indexByText.get(key);
                break;
            }
        }

        if (index == null) {
            return '';
        }

        // We expect no more than 10 lines of Description
        String[] descriptions = new String[] {};
        for (Integer i = index; index < index + 10; i++) {

            String text = ocrByIndex.get(i).getLine();

            if (text.equals('DATE')) {
                break;
            }

            descriptions.add(text);
        }

        return String.join(descriptions, '\n');
    }
}