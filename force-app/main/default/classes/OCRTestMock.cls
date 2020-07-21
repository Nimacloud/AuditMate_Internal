@isTest
public with sharing class OCRTestMock {

    public class OCRSchindlerTestMock implements HttpCalloutMock {

        private Integer status;

        public OCRSchindlerTestMock() {
            this.status = 200;
        }

        public OCRSchindlerTestMock(Integer status) {
            this.status = status;
        }

        public HTTPResponse respond(HTTPRequest request) {

            HttpResponse response = new HttpResponse();

            response.setBody(getBodySchindler());
            response.setStatusCode(status);

            if (status == 500) {
                response.setBody('error');
            }

            return response;
        }
    }

    public class OCRThyssenTestMock implements HttpCalloutMock {

        private Integer status;

        public OCRThyssenTestMock() {
            this.status = 200;
        }

        public OCRThyssenTestMock(Integer status) {
            this.status = status;
        }

        public HTTPResponse respond(HTTPRequest request) {

            HttpResponse response = new HttpResponse();

            response.setBody(getBodyThyssen());
            response.setStatusCode(status);

            if (status == 500) {
                response.setBody('error');
            }

            return response;
        }
    }

    private static String getBodySchindler() {

        return '{ "OcrPages" : [{  "Lines" : [ {    "LineText" : "INVOICE"  }, {    "LineText" : "Local"  }, {    "LineText" : "Schindler Elevator Corporation"  }, {    "LineText" : "Invoice Number"  }, {    "LineText" : "7153082051"  }, {    "LineText" : "Office"  }, {    "LineText" : "743 MCGREGOR CT STE 140"  }, {    "LineText" : "Invoice Date"  }, {    "LineText" : "01/13/2020"  }, {    "LineText" : "Schindler"  }, {    "LineText" : "BOISE ID 83705-5225"  }, {    "LineText" : "Billing ID"  }, {    "LineText" : "1 141870"  }, {    "LineText" : "Purchase Order No"  }, {    "LineText" : "Sales Contact"  }, {    "LineText" : "Diane Rawson"  }, {    "LineText" : "Field Contact"  }, {    "LineText" : "Charles Pogue"  }, {    "LineText" : "Bill"  }, {    "LineText" : "LA QUINTA INN & SUITES"  }, {    "LineText" : "Telephone"  }, {    "LineText" : "208 577 5525"  }, {    "LineText" : "to"  }, {    "LineText" : "539 POLELINE RD"  }, {    "LineText" : "Fax"  }, {    "LineText" : "208 577 5526"  }, {    "LineText" : "TWIN FALLS ID 83301-3099"  }, {    "LineText" : "Federal Tax ID"  }, {    "LineText" : "34 127 0056"  }, {    "LineText" : "DUNS Number"  }, {    "LineText" : "09 480 9993"  }, {    "LineText" : "Service"  }, {    "LineText" : "LA QUINTA INN & SUITES"  }, {    "LineText" : "Order Type"  }, {    "LineText" : "Z1 TM"  }, {    "LineText" : "Location"  }, {    "LineText" : "539 POLELINE RD"  }, {    "LineText" : "Order No"  }, {    "LineText" : "5154368932"  }, {    "LineText" : "TWIN FALLS ID 83301-3099 --"  }, {    "LineText" : "Contract"  }, {    "LineText" : "4100062624"  }, {    "LineText" : "Description"  }, {    "LineText" : "Price"  }, {    "LineText" : "01/03/2020 SERVICE CALL ON ONLY ELEVATOR WAS REQUESTED BY AMBER - FRONT DESK."  }, {    "LineText" : "CUSTOMER REPORTED: ONLY ELEVATOR, KEYS IN PIT."  }, {    "LineText" : "TECHNICIAN REPORTED: RETRIEVED KEYS FROM PIT AND GAVE TO ERIC."  }, {    "LineText" : "ARC EASE REFER TO OUR NOTIFICATION 000066954349"  }, {    "LineText" : "ACCOUNT :620 07.03_ A! 152, 27"  }, {    "LineText" : "Labor"  }, {    "LineText" : "83.63"  }, {    "LineText" : "Expenses"  }, {    "LineText" : "68.64"  }, {    "LineText" : "ACCOUNT _ _"  }, {    "LineText" : "Subtotal"  }, {    "LineText" : "152.27"  }, {    "LineText" : "ACCOUNT # -"  }, {    "LineText" : "will. sApplied-unless an exemption certificate is on file"  }, {    "LineText" : "Tax"  }, {    "LineText" : "2.00"  }, {    "LineText" : "AFTERUSEINET PAYABLE UPON RECEIPT"  }, {    "LineText" : "Total Invoice Amount"  }, {    "LineText" : "$152.27"  }, {    "LineText" : "DATE 1/2120"  }, {    "LineText" : ". ..."  }, {    "LineText" : ". .-"  }, {    "LineText" : "REMITTANCE"  }, {    "LineText" : "Please return this portion with your payment"  }, {    "LineText" : "Payer"  }, {    "LineText" : "LA QUINTA INN & SUITES"  }, {    "LineText" : "539 POLELINE RD"  }, {    "LineText" : "Invoice Number"  }, {    "LineText" : "7153082051"  }, {    "LineText" : "TWIN FALLS ID 83301-3099"  }, {    "LineText" : "Invoice Date"  }, {    "LineText" : "01/13/2020"  }, {    "LineText" : "Billing ID"  }, {    "LineText" : "1141870"  }, {    "LineText" : "Order Type"  }, {    "LineText" : "Z1TM"  }, {    "LineText" : "Remit"  }, {    "LineText" : "Schindler Elevator Corporation"  }, {    "LineText" : "Use this address for payments only. &#124;Order Number"  }, {    "LineText" : "5154368932"  }, {    "LineText" : "to"  }, {    "LineText" : "P.O. Box 93050"  }, {    "LineText" : "Direct calls and co"  }, {    "LineText" : "Chicago, IL 60673-3050"  }, {    "LineText" : "to our Local Office above."  }, {    "LineText" : "INVOICE AMOUNT $152.27"  }, {    "LineText" : "Invoices not paid within 30 days are subject to a service charge of 1.5% per month, or the maximum permitted by law."  }, {    "LineText" : "Seller represents that with respect to the production of the articles and/or the performance of the"  }, {    "LineText" : "services covered by this invoice, it has fully complied with the Fair Labor Standards Act of 1938, as amended."  } ],  "Successful" : true,  "PageNumber" : 1}] }';
    }

    private static String getBodyThyssen() {

        return '{ "OcrPages" : [{  "Lines" : [ {    "LineText" : "Page 1 of 1"  }, {    "LineText" : "thyssenkrupp"  }, {    "LineText" : "INVOICE"  }, {    "LineText" : "thyssenkrupp Elevator Corporation"  }, {    "LineText" : "INVOICE DATE:"  }, {    "LineText" : "11/26/2019"  }, {    "LineText" : "Attn: Accounts Receivable Dept"  }, {    "LineText" : "CUSTOMER #:"  }, {    "LineText" : "74682"  }, {    "LineText" : "1265 E FORT UNION BLVD , SUITE 350"  }, {    "LineText" : "COTTONWOOD HEIGHTS, UT 84047"  }, {    "LineText" : "SR #:"  }, {    "LineText" : "46138352"  }, {    "LineText" : "INVOICE #:"  }, {    "LineText" : "5001 187136"  }, {    "LineText" : "PO #:"  }, {    "LineText" : "TERMS:"  }, {    "LineText" : "IMMEDIATE"  }, {    "LineText" : "TOTAL DUE:"  }, {    "LineText" : "$641.90"  }, {    "LineText" : "BILL TO:"  }, {    "LineText" : "COMFORT SUITES REDMOND"  }, {    "LineText" : "VESTA REDMOND LLC"  }, {    "LineText" : "SHIP TO:"  }, {    "LineText" : "2243 SW YEW AVE"  }, {    "LineText" : "REDMOND, OR 97756-8636"  }, {    "LineText" : "COMFORT SUITES REDMOND"  }, {    "LineText" : "2243 SW YEW AVE"  }, {    "LineText" : "REDMOND, OR 97756-8636"  }, {    "LineText" : "Reported By: TAMMY SMITH, 541-504-8900 on 16-Nov-2019 09:47:00"  }, {    "LineText" : "Resolution Summary: CUSTOMER REPORTED THAT ELEVATOR 1 IS NOT RESPONDING TO CALLS. OVERTIME APPORVED. MECHANIC"  }, {    "LineText" : "REPLACED ALL RELAYS, ADJUSTED VALVE TO KEEP FROM OVERSHOOTING THE FLOORS, OBSERVED OPERATION AND RETURNED UNIT TO"  }, {    "LineText" : "SERVICE."  }, {    "LineText" : "DATE"  }, {    "LineText" : "DESCRIPTION"  }, {    "LineText" : "QTY"  }, {    "LineText" : "UOM"  }, {    "LineText" : "PRICE"  }, {    "LineText" : "AMOUNT"  }, {    "LineText" : "PORTLAND BRANCH"  }, {    "LineText" : "Unit: 1 Serial #: US122059"  }, {    "LineText" : "Contract #: US48387"  }, {    "LineText" : "Platinum - Full Maintenance, Overtime portion not covered - Elevator"  }, {    "LineText" : "11/16/2019"  }, {    "LineText" : "Travel Overtime"  }, {    "LineText" : ".5"  }, {    "LineText" : "HF"  }, {    "LineText" : "$366.80"  }, {    "LineText" : "$183.40"  }, {    "LineText" : "11/16/2019"  }, {    "LineText" : "Labor Callback Overtime"  }, {    "LineText" : "HR"  }, {    "LineText" : "$366.80"  }, {    "LineText" : "$366.80"  }, {    "LineText" : "1/16/2019"  }, {    "LineText" : "Travel Overtime"  }, {    "LineText" : "HR"  }, {    "LineText" : "$366.80"  }, {    "LineText" : "$91.70"  }, {    "LineText" : "AMOUNT"  }, {    "LineText" : "SALES TAX"  }, {    "LineText" : "PLEASE PAY THIS AMOUNT"  }, {    "LineText" : "641.90"  }, {    "LineText" : "$0.00"  }, {    "LineText" : "$641.90"  }, {    "LineText" : "This charge was created because service was not covered by maintenance contracts you may have with thyssenkrupp Elevator."  }, {    "LineText" : "For Service Related or General Questions, please call 503-255-0079 . For Billing or Payment Questions, please call 770-799-0479 ."  }, {    "LineText" : "DETACH AND RETURN WITH YOUR PAYMENT"  }, {    "LineText" : "thyssenkrupp"  }, {    "LineText" : "INVOICE DATE:"  }, {    "LineText" : "11/26/2019"  }, {    "LineText" : "CUSTOMER #:"  }, {    "LineText" : "74682"  }, {    "LineText" : "thyssenkrupp Elevator Corporation"  }, {    "LineText" : "SR #"  }, {    "LineText" : "46138352"  }, {    "LineText" : "Attn: Accounts Receivable Dept"  }, {    "LineText" : "INVOICE #:"  }, {    "LineText" : "5001187136"  }, {    "LineText" : "1265 E FORT UNION BLVD , SUITE 350"  }, {    "LineText" : "PO #:"  }, {    "LineText" : "COTTONWOOD HEIGHTS, UT 84047"  }, {    "LineText" : "TERMS:"  }, {    "LineText" : "IMMEDIATE"  }, {    "LineText" : "TOTAL DUE:"  }, {    "LineText" : "641.90"  }, {    "LineText" : "Amount Enclosed: $"  }, {    "LineText" : "REMIT PAYMENT TO:"  }, {    "LineText" : "Payment Method"  }, {    "LineText" : "a Personal check enclosed a Money order enclosed a Cashier\'s check"  }, {    "LineText" : "thyssenkrupp Elevator Corporation"  }, {    "LineText" : "PO Box 3796"  }, {    "LineText" : "Please Make Check Payment To"  }, {    "LineText" : "thyssenkrupp Elevator Corporation"  }, {    "LineText" : "Carol Stream, IL 60132-3796"  } ],  "Successful" : true,  "PageNumber" : 1}] }';
    }
}