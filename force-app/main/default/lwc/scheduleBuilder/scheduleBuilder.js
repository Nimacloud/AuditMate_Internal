import { LightningElement, track, api } from 'lwc';
import momentResource from '@salesforce/resourceUrl/momentMin';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getServiceData from '@salesforce/apex/opportunityController.getServiceData';

export default class ScheduleBuilder extends LightningElement {

  @track dateDuration;
  @track error;
  @track _startDate;
  @track _endDate;
  @track _duration;
  startDateString;
  endDateString;
  localCopy;

  STRINGS = {
    nodiff: '',
    year: 'year',
    years: 'years',
    month: 'month',
    months: 'months',
    day: 'day',
    days: 'days',
    hour: 'hour',
    hours: 'hours',
    minute: 'minute',
    minutes: 'minutes',
    second: 'second',
    seconds: 'seconds',
    delimiter: ' '
  };

  @api
  get startDate() {
    return this._startDate;
  }

  set startDate(value) {
    this._startDate = value;
    this.setAttribute('startDate', this._startDate);
  }

  //@api
 // get startDateString() {
  //  return this._startDate.format("ddd MM, YYYY");  
 // }

//  set startDateString(value) {
//    this._startDate   = new moment(value, "YYYY-MM-DD");   
//  this._startDate = value;
 //   this.setAttribute('startDate', this._startDate);
//  }

  @api
  get endDate() {
    return this._endDate;
  }

  set endDate(value) {
    this._endDate = value;
    this.setAttribute('endDate', this._endDate);
  }  
  
 // @api
 // get endDateString() {
 //   return this._endDate.format("ddd MM, YYYY");  
 // }

//  set endDateString(value) {
 //   this._endDate   = new moment(value, "YYYY-MM-DD");   
//  this._startDate = value;
  //  this.setAttribute('endDate', this._startDate);
//  }

  @api
  get duration() {
    return this._duration;
  }

  set duration(value) {
    this._duration = value;
    this.setAttribute('duration', this._duration);
  }

  getData() {
    getServiceData({id: this.recordId}).then(result => {
      this.localCopy = JSON.parse(JSON.stringify(result));
      this.createHistoryTable();
      console.log('localCopy',this.localCopy);
  //    this.createSummaryTable();
      this.error = undefined;
    }).catch(error => {
      console.log('error ... ' , error);
    });
  }

  /* 
  renderedCallback() {
    console.log('renderedCallback _startDate');
    console.log(this._startDate);
    this.startDate = this._startDate;
  }
*/

  connectedCallback() {
    if(this.recordId) {
      console.log(`ScheduleBuilder.connectedCallback(v1.0.1) recordId: ${this.recordId}`);
    } else {
      this.recordId = '0066g000002MrQbAAK';
      console.log(`Schedule.connectedCallback(v1.0.1)`);
    }

    loadScript(this,momentResource)
    .then(() => { 
      this.error = undefined;
      let m = moment().format();
      let msg = `Loaded Moment library ${m}`;
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'OK',
          message: msg,
          variant: 'success',
        }),
      );
      this.startDateString = new moment('2019-01-01', 'YYYY-MM-DD').format('ddd MM, YYYY');
      this.endDateString   = new moment('2020-01-01', 'YYYY-MM-DD').format('ddd MM, YYYY'); 
      this._startDate   = new moment('2019-01-01', 'YYYY-MM-DD');
      this._endDate     = new moment('2020-01-01', 'YYYY-MM-DD');
      const startMoment = new moment('2019-01-01', 'YYYY-MM-DD');
      const endMoment   = new moment('2020-01-01', 'YYYY-MM-DD');
      this._duration    = this.preciseDiff(endMoment, startMoment); 
      console.log('Test Dates');
      console.log(this.startDate);
      console.log(this.endDate);
      this.getData(); 
    })
    .catch(error => {
      this.error = error;
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error!!',
          message: error.message,
          variant: 'error',
        }),
      );
    });
    
  }

  handleClick(event) {
    const btn = event.target.name;
    console.log('clicked:' , btn); 
  }

  handleChange(event) {
    let tempDurObj;
    const field = event.target.name;
    const val   = event.target.value;
    console.log('changed:' , field, val); 
    switch(field) {
      case 'start-date' :
//      this._startDate = val;
        this.startDateString = val;
        this._startDate = new moment(this.startDateString,'YYYY-MM-DD');
        break;
      case 'end-date' :
//        this._endDate   = val;
        this.endDateString = val;
        this._endDate   = new moment(this.endDateString,'YYYY-MM-DD'); 
        break;
      default : 
       //  
    }

    // if(this.startDateString && this._endDate) {
  //    const startMoment = new moment(this._startDate,'YYYY-MM-DD');
 //     const endMoment   = new moment(this._endDate,'YYYY-MM-DD');
  //    console.log(':1:',startMoment.format(), ':2:',endMoment.format());
//      this._duration     = this.preciseDiff(endMoment, startMoment); 
      this._duration     = this.preciseDiff(this._endDate, this._startDate); 
//      this.dateDuration = this.duration;
//      tempDurObj = this.preciseDiff(endMoment, startMoment, true); 
      console.log('A',this.duration);
 //     console.log('B',this.dateDuration);
 //     console.log('C',tempDurObj);
    // }
  }

  createHistoryTable() {
    const tblDiv      = document.createElement('div');
    const tbl         = document.createElement('table');
    const cap         = document.createElement('caption');
    cap.innerHTML     = 'Service History';
    const header      = tbl.createTHead();

    let colArray,colDate,colMototion,colResult;
    let hdrRow,hdrCell,tblRow,tblCell,totalTime = 0, onsiteDuration = 0, startMoment,endMoment;
    let i=0;

    this.localCopy.forEach(oppRec => {

      console.log('oppRec',oppRec);
      let arrival , departure;
      oppRec.Service_Histories__r.forEach(rec => {
        i++;
        console.log(`oppRec:${i} - ${rec}`);
        totalTime = 0;
        tblRow  = tbl.insertRow(-1);
        tblCell = tblRow.insertCell(-1);
        tblCell.innerHTML = rec.Service_Report_Date__c;

        tblCell = tblRow.insertCell(-1);
        tblCell.innerHTML = rec.Technician__c;

        startMoment    = new moment(rec.Technician_Arrival_DateTime__c);
        endMoment      = new moment(rec.Technician_Departure_DateTime__c);
        arrival        = startMoment.format('dddd, MMMM Do YYYY, h:mm:ss a');
        departure      = endMoment.format('dddd, MMMM Do YYYY, h:mm:ss a');
        onsiteDuration = this.preciseDiff(endMoment, startMoment, true); 
        console.log('Arrived:',arrival,'Depart:',departure);

        tblCell = tblRow.insertCell(-1);
        tblCell.innerHTML = arrival;

        tblCell = tblRow.insertCell(-1);
        tblCell.innerHTML = departure;

        tblCell = tblRow.insertCell(-1);
        tblCell.innerHTML = onsiteDuration.hours + ':' +  onsiteDuration.minutes;

        tblCell = tblRow.insertCell(-1);
        tblCell.innerHTML = rec.Standard_Onsite_time__c;
        tblCell = tblRow.insertCell(-1);
        tblCell.innerHTML = rec.Standard_Travel_time__c;
  
        tblCell = tblRow.insertCell(-1); 
        tblCell.innerHTML = rec.Overtime_Onsite_time__c;
        tblCell = tblRow.insertCell(-1);
        tblCell.innerHTML = rec.Overtime_Travel_time__c;
        tblCell = tblRow.insertCell(-1);
        tblCell.innerHTML = rec.Doubletime_Onsite_time__c;
        tblCell = tblRow.insertCell(-1);
        tblCell.innerHTML = rec.Doubletime_Travel_time__c;
  
        tblCell = tblRow.insertCell(-1);
        totalTime = rec.Standard_Onsite_time__c + rec.Standard_Travel_time__c + rec.Overtime_Onsite_time__c + rec.Doubletime_Onsite_time__c + rec.Doubletime_Travel_time__c;
        tblCell.innerHTML = totalTime.toFixed(2);
      });
    });

    header.className  = 'table-header';
    tblDiv.className  = 'slds-scrollable_x';
    tbl.className     = 'slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered';

    // 1st header row
    hdrRow            = header.insertRow(-1);
    hdrRow.className  = 'header-row';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Call Date';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Technician';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Arrived';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Departed';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Duration';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Standard Time';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Standard Travel';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Overtime Time';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Overtime Travel';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Doubletime Time';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Doubletime Travel';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Total Time';    

    tbl.appendChild(cap);
    tblDiv.appendChild(tbl);
    const container = this.template.querySelector('.summary-container');
    container.className = 'table-container slds-m-around_medium slds-box';
    container.innerHTML = '';
    container.appendChild(tblDiv);

  }

  createSummaryTable() {
    const tblDiv      = document.createElement('div');
    const tbl         = document.createElement('table');
    const cap         = document.createElement('caption');
    cap.innerHTML     = 'Service Summary';
    const header      = tbl.createTHead();

//  let voteColCnt = this.keysArray.length;
    let colArray,colDate,colMototion,colResult;
    let hdrRow,hdrCell,tblRow,tblCell;

    header.className  = 'table-header';
    tblDiv.className  = 'slds-scrollable_x';
    tbl.className     = 'slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered';

    // 1st header row
    hdrRow            = header.insertRow(-1);
    hdrRow.className  = 'header-row';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Date of visit';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Type';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Arrived';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Departed';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Duration';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Travel Time';

    hdrCell           = hdrRow.insertCell(-1);
    hdrCell.className = 'header-cell';
    hdrCell.innerHTML = 'Total Time';

    tbl.appendChild(cap);
    tblDiv.appendChild(tbl);
    const container = this.template.querySelector('.table-container');
    container.className = 'table-container slds-m-around_medium slds-box';
    container.innerHTML = '';
    container.appendChild(tblDiv);

  }

  // ----------------------------------------------------------------------
  // preciseDiff code from https://github.com/codebox/moment-precise-range
  // ----------------------------------------------------------------------
  preciseDiff(d1, d2, returnValueObject) {
    let m1 = moment(d1), m2 = moment(d2), firstDateWasLater;
    
    m1.add(m2.utcOffset() - m1.utcOffset(), 'minutes'); // shift timezone of m1 to m2
    
    if (m1.isSame(m2)) {
      if (returnValueObject) {
        return this.buildValueObject(0, 0, 0, 0, 0, 0, false);
      } else {
        return this.STRINGS.nodiff;
      }
    }
    if (m1.isAfter(m2)) {
        let tmp = m1;
        m1 = m2;
        m2 = tmp;
        firstDateWasLater = true;
    } else {
        firstDateWasLater = false;
    }
    
    let yDiff = m2.year() - m1.year();
    let mDiff = m2.month() - m1.month();
    let dDiff = m2.date() - m1.date();
    let hourDiff = m2.hour() - m1.hour();
    let minDiff = m2.minute() - m1.minute();
    let secDiff = m2.second() - m1.second();
    
    if (secDiff < 0) {
        secDiff = 60 + secDiff;
        minDiff--;
    }
    if (minDiff < 0) {
        minDiff = 60 + minDiff;
        hourDiff--;
    }
    if (hourDiff < 0) {
        hourDiff = 24 + hourDiff;
        dDiff--;
    }
    if (dDiff < 0) {
        let daysInLastFullMonth = moment(m2.year() + '-' + (m2.month() + 1), "YYYY-MM").subtract(1, 'M').daysInMonth();
        if (daysInLastFullMonth < m1.date()) { // 31/01 -> 2/03
            dDiff = daysInLastFullMonth + dDiff + (m1.date() - daysInLastFullMonth);
        } else {
            dDiff = daysInLastFullMonth + dDiff;
        }
        mDiff--;
    }
    if (mDiff < 0) {
        mDiff = 12 + mDiff;
        yDiff--;
    }
    
    if (returnValueObject) {
        return this.buildValueObject(yDiff, mDiff, dDiff, hourDiff, minDiff, secDiff, firstDateWasLater);
    } else {
        return this.buildStringFromValues(yDiff, mDiff, dDiff, hourDiff, minDiff, secDiff);
    }
   }	

   buildStringFromValues(yDiff, mDiff, dDiff, hourDiff, minDiff, secDiff){
    let result = [];

    if (yDiff) {
        result.push(this.pluralize(yDiff, 'year'));
    }
    if (mDiff) {
        result.push(this.pluralize(mDiff, 'month'));
    }
    if (dDiff) {
        result.push(this.pluralize(dDiff, 'day'));
    }
    if (hourDiff) {
        result.push(this.pluralize(hourDiff, 'hour'));
    }
    if (minDiff) {
        result.push(this.pluralize(minDiff, 'minute'));
    }
    if (secDiff) {
        result.push(this.pluralize(secDiff, 'second'));
    }

    return result.join(this.STRINGS.delimiter);
  }

  buildValueObject(yDiff, mDiff, dDiff, hourDiff, minDiff, secDiff, firstDateWasLater) {
    return {
      "years"   : yDiff,
      "months"  : mDiff,
      "days"    : dDiff,
      "hours"   : hourDiff,
      "minutes" : minDiff,
      "seconds" : secDiff,
      "firstDateWasLater" : firstDateWasLater
    }
  }

  pluralize(num, word) {
    return num + ' ' + this.STRINGS[word + (num === 1 ? '' : 's')];
  }
  // ------------------------------------------------------------------------
  // See description at https://codebox.org.uk/pages/moment-date-range-plugin
  // ------------------------------------------------------------------------

}