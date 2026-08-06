function ISRadialMenu:updateSlice(oldtext, newtext, newtexture, newcommand, arg1, arg2, arg3, arg4, arg5, arg6)
	for sliceIndex, slice in ipairs(self.slices) do
		if slice.text == oldtext then
			if newtext then
				slice.text = newtext
				if self.javaObject then
					self.javaObject:setSliceText(sliceIndex-1, newtext)
				end
			end
			if newtexture then
				slice.texture = newtexture
				if self.javaObject then
					self.javaObject:setSliceTexture(sliceIndex-1, newtexture)
				end
			end
			if newcommand == false then
                slice.command = { nil, nil, nil, nil, nil, nil, nil }
            elseif newcommand then
				slice.command = { newcommand, arg1, arg2, arg3, arg4, arg5, arg6 }
			end
			return true
		end
	end
	return false
end
