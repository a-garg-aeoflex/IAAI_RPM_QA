/**
* @author LevDigital
* @date 2021
*
* @group Contact
* @group-content ../../ApexDocContent/ContentDocumentLink.htm
*
* @description ContentDocumentLinkTrigger, calls ContentDocumentLinkHandler
*/

trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update, before delete, 
after insert, after update, after delete, after undelete) {
    static Integer afterInsertCount = 0;
    afterInsertCount ++;
    System.debug(' afterInsertCount1:' +  afterInsertCount);
    TriggerHandler.getInstance('ContentDocumentLinkHandler', false).runHandler();  
}