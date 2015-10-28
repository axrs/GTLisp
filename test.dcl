GT_PlotDialog : dialog { 
         label = "GTLISP - Batch Plot"; 
          : column { 
            : row {
                : list_box {
                  label ="Select Layouts to Plot";
                  key = "layerList";
                  height = 10;
                  width = 10;
                  multiple_select = true;
                  fixed_width_font = true;
                  value = "";
                }
              
            }
            : row { 
              : button {
                key = "accept";
                label = " Plot ";
                is_default = true;
              }
              : button {
                key = "cancel";
                label = " Close ";
                is_default = false;
                is_cancel = true;
              } 
            }   
          }

}