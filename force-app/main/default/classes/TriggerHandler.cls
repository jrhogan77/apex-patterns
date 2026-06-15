public virtual with sharing class TriggerHandler {

    @TestVisible private static Boolean bypassAll = false;
    @TestVisible private static Set<String> bypassed = new Set<String>();

    public void run() {
        if (!validate()) return;
        if (Trigger.isBefore) {
            if (Trigger.isInsert)   beforeInsert();
            if (Trigger.isUpdate)   beforeUpdate();
            if (Trigger.isDelete)   beforeDelete();
            if (Trigger.isUndelete) beforeUndelete();
        } else {
            if (Trigger.isInsert)   afterInsert();
            if (Trigger.isUpdate)   afterUpdate();
            if (Trigger.isDelete)   afterDelete();
            if (Trigger.isUndelete) afterUndelete();
        }
    }

    public static void bypass(String handler)      { bypassed.add(handler); }
    public static void clearBypass(String handler) { bypassed.remove(handler); }
    public static void bypassAll()                 { bypassAll = true; }
    public static void clearAll()                  { bypassAll = false; bypassed.clear(); }

    private Boolean validate() {
        if (!Trigger.isExecuting) return false;
        if (bypassAll) return false;
        String name = String.valueOf(this).substringBefore(':');
        return !bypassed.contains(name);
    }

    protected virtual void beforeInsert()   {}
    protected virtual void beforeUpdate()   {}
    protected virtual void beforeDelete()   {}
    protected virtual void beforeUndelete() {}
    protected virtual void afterInsert()    {}
    protected virtual void afterUpdate()    {}
    protected virtual void afterDelete()    {}
    protected virtual void afterUndelete()  {}
}
