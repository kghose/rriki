// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//from http://en.wikipedia.org/w/skins-1.5/common/wikibits.js?29
function insert_link(tagOpen, tagClose, sampleText, txtarea)
{
    if(txtarea.selectionStart || txtarea.selectionStart == '0') 
    {
        var replaced = false;
    var startPos = txtarea.selectionStart;
    var endPos = txtarea.selectionEnd;
    if (endPos-startPos) 
        {
      replaced = true;
    }
    var scrollTop = txtarea.scrollTop;
    var myText = (txtarea.value).substring(startPos, endPos);
    if (!myText) 
        {
      myText=sampleText;
    }
    var subst;
    if (myText.charAt(myText.length - 1) == " ") 
        { // exclude ending space char, if any
      subst = tagOpen + myText.substring(0, (myText.length - 1)) + tagClose + " ";
    } 
        else 
        {
      subst = tagOpen + myText + tagClose;
    }
    txtarea.value = txtarea.value.substring(0, startPos) + subst +
      txtarea.value.substring(endPos, txtarea.value.length);
    txtarea.focus();
    //set new selection
    if (replaced) 
        {
      var cPos = startPos+(tagOpen.length+myText.length+tagClose.length);
      txtarea.selectionStart = cPos;
      txtarea.selectionEnd = cPos;
    } 
        else 
        {
      txtarea.selectionStart = startPos+tagOpen.length;
      txtarea.selectionEnd = startPos+tagOpen.length+myText.length;
    }
    txtarea.scrollTop = scrollTop;
  }
}

// This function can be called with a string corresponding to a div id, and
// it will call AMprocessNode which then goes through the text in a node and
// runs the ASCIIMathML magic on that text and updates that div
// You can call this function while doing an update in a controller as
//    render :update do |page|    
//      page.call 'display', 'item-body'
//    end 
// assuming 'item-body' is the div in question
function display(divid) {
  var outnode = document.getElementById(divid);
  AMprocessNode(outnode);
}
