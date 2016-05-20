public class trailheadLeaderBoardController
{
    public List<ContactWrapper> contacts;
    public Contact contender {get; set;}
    public boolean submitted {get; set;}
    Integer x {get; set;}
    Integer pageSize {get; set;}
    List<Contact> contactsInList {get; set;}
    
    public ApexPages.StandardSetController con{
        get{
            //Choose Trailhead contacts
            if(con == null){
                con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Name, FirstName, LastName, 
                                                                                    Badges__c, Total_Points__c, Trailhead_URL__c, SF_Dev_User_Id__c 
                        from Contact 
                        Where RecordTypeId = '012360000003Myc'
                        Order by Badges__c DESC, Total_Points__c DESC]));
                con.setPageSize(pageSize);
            }
            return con;
        }
        set;
    }
    
    public trailheadLeaderBoardController()
    {
    
        this.x = 1;
        this.pageSize = 20;
        this.contender = new Contact();
        if(ApexPages.currentPage().getParameters().get('submitted') == 'true'){
            submitted = true;
        }
        else{
            submitted = false;
        }
        this.contactsInList = [Select Id, Name, FirstName, LastName, Badges__c, Total_Points__c, Trailhead_URL__c, SF_Dev_User_Id__c
                        from Contact 
                        Where RecordTypeId = '012360000003Myc'
                        Order by Badges__c DESC, Total_Points__c DESC];
    }
    
    public class ContactWrapper
    {
        public Integer count{get;set;}
        public Contact c {get;set;}
        public Integer badgeTotal {get;set;}
        
        public ContactWrapper(Contact c, Integer x)
        {
            this.c = c;
            count = x;
            this.badgeTotal = (Integer)c.Badges__c;
            
        }
    }
    
    public List<ContactWrapper> getContacts() {
        System.debug('Get contacts reached');
        contacts = new List<ContactWrapper>();
        List<Contact> contactsInList = (List<Contact>)con.getRecords();
        Integer badges = (Integer)contactsInList[0].Badges__c;
        System.debug('Total contacts in list ' + contactsInList.size());
        for(Contact c : contactsInList)
        {
            if(c.Badges__c != badges){
                x++;
                badges = (Integer) c.Badges__c;
            }
            contacts.add(new ContactWrapper(c,x));
        }

        return contacts;
    }

    public PageReference launchTrailhead(){
        PageReference p = new PageReference('https://developer.salesforce.com/trailhead');
        p.setRedirect(false);
        return p;
    }

    public PageReference createContender(){
        contender.LeadSource = 'Blog';
        contender.RecordTypeID = '012o0000000pdzS';

        try{
            insert contender;
            submitted = true;
            return new PageReference('/?submitted=true');
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Contact Failed to Create'));
            return null;
        }
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    // returns the first page of records
     public void first() {
         con.first();
         x = 1;
     }

     // returns the last page of records
     public void last() {
         con.last();
        Integer y = 0;
        Contact conToUse = (Contact)con.getRecords()[0];
        Integer badges = (Integer)conToUse.Badges__c;
        for(Contact c : contactsInList)
        {
            if(c.Badges__c != badges){
                y++;
                badges = (Integer) c.Badges__c;
            }
            if(c.Id == conToUse.Id){
                x = y;
            }
        }
     }

     // returns the previous page of records
     public void previous() {
         con.previous();
        Integer y = 0;
        Contact conToUse = (Contact)con.getRecords()[0];
        Integer badges = (Integer)conToUse.Badges__c;
        for(Contact c : contactsInList)
        {
            if(c.Badges__c != badges){
                y++;
                badges = (Integer) c.Badges__c;
            }
            if(c.Id == conToUse.Id){
                x = y;
            }
            if(conToUse.Id == contactsInList[0].Id){
                x = 1;
            }
        }
     }

     // returns the next page of records
     public void next() {
         con.next();
        Integer y = 0;
        Contact conToUse = (Contact)con.getRecords()[0];
        Integer badges = (Integer)conToUse.Badges__c;
        for(Contact c : contactsInList)
        {
            if(c.Badges__c != badges){
                y++;
                badges = (Integer) c.Badges__c;
            }
            if(c.Id == conToUse.Id){
                x = y;
            }
        }
     }

     // returns the PageReference of the original page, if known, or the home page.
     public void cancel() {
         con.cancel();
     }


}