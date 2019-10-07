import QtQuick 2.0
import MuseScore 3.0
import QtQuick.Dialogs 1.1
import Qt.labs.settings 1.0

MuseScore {
      menuPath: "Plugins.moveBreaksToParts"
      description: "This plugin moves breaks from the score to parts."
      version: "1.0"
      requiresScore: true
      onRun: {
            if (!curScore)
                  Qt.quit();
            
            if ((mscoreMajorVersion < 3) || (mscoreMinorVersion < 3)) {
                  versionError.open();
                  Qt.quit();
            } else if (curScore.selection.elements.length == 0) {
                  selectionError.open();
                  Qt.quit();
            } else if (curScore.selection.elements[0].type != Element.LAYOUT_BREAK ){
                  selectionError.open();
                  Qt.quit();
            }else {
                  curScore.startCmd();
                  cmd("select-similar");
                  
                  var elements = curScore.selection.elements;
                  
                  var cursor = curScore.newCursor();
                  cursor.track = 0;
                  
                  var measNoPageBreak;
                  var measNoLineBreak;
                  var measNoSectionBreak;
                  var measNoNoBreak;
                  if (elements.length > 0) {  // We have a selection list to work with...
                        console.log(elements.length, "selections")
                        for (var idx = 0; idx < elements.length; idx++) {
                              var element = elements[idx];
                              if (element.type == Element.LAYOUT_BREAK ) {
                                    if (element.layoutBreakType == 2 || element.layoutBreakType == 4){
                                          
                                          var tick = element.parent.tick;
                                          cursor.rewind(0);
                                          do {
                                                if (cursor.tick == tick) {
                                                      var meaNo = findMeasureNumber(cursor.measure) + 1
                                                      if (mark.text == "mea")
                                                            mark.text = meaNo;
                                                      console.log("We found the tick!");
                                                      if (meaNo > 1)
                                                            cursor.add(mark.clone());
                                                      break;
                                                }
                                          } while (cursor.next())
                                    }
                              }
                        }
                  }
                  cmd("resequence-rehearsal-marks");
                  
                  curScore.endCmd();
                  Qt.quit();
            }
      }
      
      function findMeasureNumber (mea) {
            if (!mea) {
                  console.log("findMeasureNumber: no measure");
                  return 0;
            }
            
            var ms = mea
            var i = 1;
            while (ms.prev) {
                  ms = ms.prev;
                  if (ms.is (curScore.firstMeasure))
                        return i;
                  // todo: don't count measure if excluded from measure count
                  console.log(i)
                  i++;
            }
            if (i > 1){
                  console.log("findMeasureNumber: measure not found");
                  return 0;
            }
            return 1; // it was measure number 1
      }
            
      MessageDialog {
            id: versionError
            visible: false
            title: qsTr("Unsupported MuseScore version")
            text: qsTr("This plugin needs MuseScore 3.3 or later.")
            onAccepted: {
                  Qt.quit()
            }
      }
      MessageDialog {
            id: selectionError
            visible: false
            title: qsTr("Plugin selection error")
            text: qsTr("Please select a line break before running this plugin.")
            onAccepted: {
                  Qt.quit()
            }
      }
}