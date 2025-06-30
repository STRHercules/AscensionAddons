local oldOnShow = StaticPopupDialogs["DELETE_GOOD_ITEM"].OnShow
StaticPopupDialogs["DELETE_GOOD_ITEM"].OnShow = function(frame)
    if oldOnShow then oldOnShow(frame) end
    frame.editBox:SetText("Delete")
end