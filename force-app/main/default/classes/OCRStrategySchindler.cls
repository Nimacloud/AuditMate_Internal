public with sharing class OCRStrategySchindler extends OCRStrategy {

    public OCRStrategySchindler() {
        super();
    }

    public override Schindler_Invoice_History__c createInvoice() {

        loadMaps();

        Schindler_Invoice_History__c result = new Schindler_Invoice_History__c();

        Integer index = null;
        Integer index2 = null;
        Integer boundaryIndex = 0;


        // Local Office
        index = indexByText.get('Office');
        if (index != null) {
            result.Local_Office__c = ocrByIndex.get(index + 1).getLine();
        }

        // Bill To
        index = indexByText.get('Bill');
        index2 = indexByText.get('to');

        if (index != null) {
            result.Bill_To__c = ocrByIndex.get(index + 1).getLine() + '\n';
        }

        if (index2 != null) {
            result.Bill_To__c += ocrByIndex.get(index2 + 1).getLine();
        }


        // Service Location
        index = indexByText.get('Service');
        index2 = indexByText.get('Location');

        if (index != null) {
            result.Service_Location__c = ocrByIndex.get(index + 1).getLine() + '\n';
        }

        if (index2 != null) {
            result.Service_Location__c += ocrByIndex.get(index2 + 1).getLine();
        }

        // Invoice Number
        index = indexByText.get('Invoice Number');
        if (index != null) {
            result.Name = ocrByIndex.get(index + 1).getLine();
        }

        // Invoice Date
        index = indexByText.get('Invoice Date');
        if (index != null) {
            String invoiceDate = ocrByIndex.get(index + 1).getLine();

            try {
                result.Invoice_Date__c = Date.parse(invoiceDate);
            }
            catch (TypeException ex) {
                result.Invoice_Date__c = null;
            }
        }

        // Billing Id
        index = indexByText.get('Billing ID');
        if (index != null) {
            result.Billing_Id__c = ocrByIndex.get(index + 1).getLine();
        }

        // Sales Contact
        index = indexByText.get('Sales Contact');
        if (index != null) {
            result.Sales_Contact__c = ocrByIndex.get(index + 1).getLine();
        }

        // Field Contact
        index = indexByText.get('Field Contact');
        if (index != null) {
            result.Field_Contact__c = ocrByIndex.get(index + 1).getLine();
        }

        // Telephone
        index = indexByText.get('Telephone');
        if (index != null) {
            result.Telephone__c = ocrByIndex.get(index + 1).getLine();
        }

        // Fax
        index = indexByText.get('Fax');
        if (index != null) {
            result.Fax__c = ocrByIndex.get(index + 1).getLine();
        }

        // Federal Tax ID
        index = indexByText.get('Federal Tax ID');
        if (index != null) {
            result.Federal_Tax_Id__c = ocrByIndex.get(index + 1).getLine();
        }

        // DUNS Number
        index = indexByText.get('DUNS Number');
        if (index != null) {
            result.Duns_Number__c = ocrByIndex.get(index + 1).getLine();
        }

        // Order Type
        index = indexByText.get('Order Type');
        if (index != null) {
            result.Order_Type__c = ocrByIndex.get(index + 1).getLine();
        }

        // Order Number
        index = indexByText.get('Order No');
        if (index != null) {
            result.Order_No__c = ocrByIndex.get(index + 1).getLine();
        }

        // Contract
        index = indexByText.get('Contract');
        if (index != null) {
            result.Contract__c = ocrByIndex.get(index + 1).getLine();
        }

        // Description
        index = indexByText.get('Description');
        if (index != null) {
            boundaryIndex = indexByText.get('Labor');

            if (boundaryIndex != null) {

                String[] descriptions = new String[] {};

                for (Integer i = index; i < boundaryIndex - 1; i++) {
                    descriptions.add(ocrByIndex.get(i + 1).getLine());
                }

                result.Description__c = String.join(descriptions, '\n');
            }
        }

        // Labor
        index = indexByText.get('Labor');
        if (index != null) {
            String labor = ocrByIndex.get(index + 1).getLine();

            if (labor != null) {
                labor = labor.remove('$');

                try {
                    result.Labor__c = Decimal.valueOf(labor);
                }
                catch (TypeException ex) {
                    result.Labor__c = null;
                }
            }
        }

        // Expenses
        index = indexByText.get('Expenses');
        if (index != null) {
            String expenses = ocrByIndex.get(index + 1).getLine();

            if (expenses != null) {
                expenses = expenses.remove('$');

                try {
                    result.Expenses__c = Decimal.valueOf(expenses);
                }
                catch (TypeException ex) {
                    result.Expenses__c = null;
                }
            }
        }

        // Subtotal
        index = indexByText.get('Subtotal');
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
        index = indexByText.get('Tax');
        if (index != null) {
            String tax = ocrByIndex.get(index + 1).getLine();

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

        // Total Invoice Amount
        index = indexByText.get('Total Invoice Amount');

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

        return result;
    }


}