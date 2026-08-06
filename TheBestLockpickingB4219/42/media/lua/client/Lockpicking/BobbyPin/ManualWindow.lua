require "ISUI/ISUIElement"
require "Lockpicking/BobbyPin/BobbyPinWindowNew"

ManualWindow = ISPanel:derive("ManualWindow")

-- Функция для извлечения только отображаемого текста без тегов
local function getVisibleText(text)
    if not text or text == "" then return "" end
    return text:gsub("<RGB:[%x][%x][%x][%x][%x][%x]>", ""):gsub("</RGB>", "")
end

-- Функция для переноса текста по словам с учётом <br> и отступов
local function wrapText(text, maxWidth, font, indentSize)
    local lines = {}
    local spaceWidth = getTextManager():MeasureStringX(font, " ")
    local punctuation = {["."] = true, [","] = true, ["!"] = true, ["?"] = true, [":"] = true, [";"] = true}

    -- Normalize <br> to \n
    local normalizedText = text:gsub("<br>", "\n")
    
    -- Split into paragraphs
    local paragraphs = {}
    for paragraph in normalizedText:gmatch("[^\n]+") do
        table.insert(paragraphs, paragraph)
    end

    for _, paragraph in ipairs(paragraphs) do
        -- Parse into units (words or tagged segments)
        local units = {}
        local pos = 1
        while pos <= #paragraph do
            local startTag = paragraph:find("<RGB:[%x][%x][%x][%x][%x][%x]>", pos)
            if startTag then
                -- Add plain text before the tag as separate words
                if startTag > pos then
                    local plainText = paragraph:sub(pos, startTag - 1)
                    for word in plainText:gmatch("%S+") do
                        table.insert(units, { type = "word", text = word })
                    end
                end
                -- Extract the tagged segment
                local endTag = paragraph:find("</RGB>", startTag)
                if endTag then
                    local taggedText = paragraph:sub(startTag, endTag + 5)
                    table.insert(units, { type = "tagged", text = taggedText })
                    pos = endTag + 6
                else
                    -- No end tag, treat remaining text as plain words
                    local remainingText = paragraph:sub(pos)
                    for word in remainingText:gmatch("%S+") do
                        table.insert(units, { type = "word", text = word })
                    end
                    break
                end
            else
                -- No more tags, add remaining text as words
                local remainingText = paragraph:sub(pos)
                for word in remainingText:gmatch("%S+") do
                    table.insert(units, { type = "word", text = word })
                end
                break
            end
        end

        -- Wrap units into lines
        local currentLineUnits = {}
        local lineWidth = 0
        local unitCount = 0
        local isFirstLine = true

        for _, unit in ipairs(units) do
            local visibleText = unit.type == "word" and unit.text or getVisibleText(unit.text)
            local unitWidth = getTextManager():MeasureStringX(font, visibleText)
            local indent = isFirstLine and indentSize or 0
            local spaceAddition = unitCount > 0 and spaceWidth or 0

            if lineWidth + indent + spaceAddition + unitWidth <= maxWidth then
                table.insert(currentLineUnits, unit)
                lineWidth = lineWidth + spaceAddition + unitWidth
                unitCount = unitCount + 1
            else
                if #currentLineUnits > 0 then
                    local lineText = ""
                    for j, u in ipairs(currentLineUnits) do
                        if j > 1 then
                            -- Проверяем, начинается ли следующий элемент со знака препинания
                            local nextChar = u.text:sub(1, 1)
                            if not punctuation[nextChar] then
                                lineText = lineText .. " "
                            end
                        end
                        lineText = lineText .. u.text
                    end
                    table.insert(lines, { text = lineText, indent = isFirstLine and indentSize or 0 })
                end
                currentLineUnits = { unit }
                lineWidth = unitWidth
                unitCount = 1
                isFirstLine = false
            end
        end

        if #currentLineUnits > 0 then
            local lineText = ""
            for j, u in ipairs(currentLineUnits) do
                if j > 1 then
                    -- Проверяем, начинается ли следующий элемент со знака препинания
                    local nextChar = u.text:sub(1, 1)
                    if not punctuation[nextChar] then
                        lineText = lineText .. " "
                    end
                end
                lineText = lineText .. u.text
            end
            table.insert(lines, { text = lineText, indent = isFirstLine and indentSize or 0 })
        end
    end

    return lines
end

-- Функция для парсинга цветных тегов и рендера текста с обработкой цвета
local function renderColoredText(self, text, x, y, font)
    local segments = {}
    local pos = 1
    local defaultColor = { r = 1, g = 1, b = 1, a = 1 }

    while pos <= #text do
        local startTag, endTag = text:find("<RGB:[%x][%x][%x][%x][%x][%x]>", pos)
        if startTag then
            -- Текст перед тегом
            if startTag > pos then
                table.insert(segments, { text = text:sub(pos, startTag - 1), color = defaultColor })
            end
            -- Поиск закрывающего тега
            local closeStart, closeEnd = text:find("</RGB>", endTag + 1)
            if closeStart then
                -- Извлечение цвета
                local colorHex = text:sub(startTag + 5, startTag + 10)
                local color = {
                    r = tonumber(colorHex:sub(1, 2), 16) / 255,
                    g = tonumber(colorHex:sub(3, 4), 16) / 255,
                    b = tonumber(colorHex:sub(5, 6), 16) / 255,
                    a = 1
                }
                -- Извлечение текста между тегами
                local coloredText = text:sub(endTag + 1, closeStart - 1)
                table.insert(segments, { text = coloredText, color = color })
                pos = closeEnd + 1
            else
                break
            end
        else
            -- Остаток текста без тегов
            table.insert(segments, { text = text:sub(pos), color = defaultColor })
            break
        end
    end

    -- Отрисовка сегментов
    local xOffset = 0
    for _, segment in ipairs(segments) do
        self:drawText(segment.text, x + xOffset, y, segment.color.r, segment.color.g, segment.color.b, segment.color.a, font)
        xOffset = xOffset + getTextManager():MeasureStringX(font, segment.text)
    end
end

function ManualWindow:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.moveWithMouse = true

    -- Параметры руководства
    o.currentPage = 1
    o.pages = {}
    o.chapters = {
        { title = getText("UI_Manual_Chapter1_Title"), text = getText("UI_Manual_Chapter1_Text") },
        { title = getText("UI_Manual_Chapter2_Title"), text = getText("UI_Manual_Chapter2_Text") },
        { title = getText("UI_Manual_Chapter3_Title"), text = getText("UI_Manual_Chapter3_Text") },
        { title = getText("UI_Manual_Chapter4_Title"), text = getText("UI_Manual_Chapter4_Text") },
    }
    o.indentSize = 20  -- Размер отступа для абзацев (в пикселях)
    -- Переносим генерацию страниц в initialise
    -- o:generatePages()

    return o
end

function ManualWindow:initialise()
    ISPanel.initialise(self)
    self:generatePages()  -- Генерируем страницы после инициализации

    self.prevButton = ISButton:new(10, self.height - 30, 50, 20, getText("UI_Manual_Prev"), self, ManualWindow.onButtonClick)
    self.prevButton.internal = "PREV"
    self.prevButton:initialise()
    self.prevButton:instantiate()
    self.prevButton.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.prevButton)

    self.nextButton = ISButton:new(70, self.height - 30, 50, 20, getText("UI_Manual_Next"), self, ManualWindow.onButtonClick)
    self.nextButton.internal = "NEXT"
    self.nextButton:initialise()
    self.nextButton:instantiate()
    self.nextButton.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.nextButton)

    self.closeButton = ISButton:new(self.width - 60, self.height - 30, 50, 20, getText("UI_Manual_Close"), self, ManualWindow.onButtonClick)
    self.closeButton.internal = "CLOSE"
    self.closeButton:initialise()
    self.closeButton:instantiate()
    self.closeButton.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.closeButton)
end

function ManualWindow:generatePages()
    local maxWidth = self.width - 20 - self.indentSize
    local fontHeightSmall = getTextManager():getFontHeight(UIFont.Small)
    local fontHeightMedium = getTextManager():getFontHeight(UIFont.Medium)
    local topMargin = 40 + fontHeightMedium + 5
    local bottomMargin = 40
    local maxTextHeight = self.height - topMargin - bottomMargin
    local linesPerPage = math.floor(maxTextHeight / fontHeightSmall)

    -- Инициализация
    self.pages = {}
    self.totalPages = 0

    -- 1. Генерация страниц глав
    local chapterPages = {}
    local chapterStartIndices = {}
    local currentPageIndex = 1

    for i, chapter in ipairs(self.chapters) do
        chapterStartIndices[i] = currentPageIndex
        local wrappedLines = wrapText(chapter.text or "", maxWidth, UIFont.Small, self.indentSize)
        local currentPageLines = {}
        local lineCount = 0

        for _, lineData in ipairs(wrappedLines) do
            if lineCount >= linesPerPage then
                table.insert(chapterPages, { title = chapter.title, lines = currentPageLines })
                currentPageIndex = currentPageIndex + 1
                currentPageLines = {}
                lineCount = 0
            end
            table.insert(currentPageLines, lineData)
            lineCount = lineCount + 1
        end

        if #currentPageLines > 0 then
            table.insert(chapterPages, { title = chapter.title, lines = currentPageLines })
            currentPageIndex = currentPageIndex + 1
        end
    end

    -- 2. Генерация строк оглавления
    local tocLines = {}
    for i, chapter in ipairs(self.chapters) do
        table.insert(tocLines, {type = "toc", title = chapter.title, pageNum = chapterStartIndices[i]})
    end

    -- 3. Разбиение строк оглавления на страницы
    local tocPages = {}
    local currentTocPageLines = {}
    local tocLineCount = 0

    for _, tocLine in ipairs(tocLines) do
        if tocLineCount >= linesPerPage then
            table.insert(tocPages, { title = getText("UI_Manual_TOC_Title"), lines = currentTocPageLines })
            currentTocPageLines = {}
            tocLineCount = 0
        end
        table.insert(currentTocPageLines, tocLine)
        tocLineCount = tocLineCount + 1
    end

    if #currentTocPageLines > 0 then
        table.insert(tocPages, { title = getText("UI_Manual_TOC_Title"), lines = currentTocPageLines })
    end

    self.tocPageCount = #tocPages

    -- 4. Объединение страниц оглавления и глав
    self.pages = {}
    for _, page in ipairs(tocPages) do
        table.insert(self.pages, page)
    end
    for _, page in ipairs(chapterPages) do
        table.insert(self.pages, page)
    end
    self.totalPages = #self.pages

    print("Total pages generated: " .. self.totalPages)
    print("TOC pages: " .. self.tocPageCount)
end

function ManualWindow:render()
    ISPanel.render(self)

    self:drawText(getText("UI_Manual_Title"), 10, 10, 1, 1, 1, 1, UIFont.Medium)

    local fontHeightSmall = getTextManager():getFontHeight(UIFont.Small)
    local fontHeightMedium = getTextManager():getFontHeight(UIFont.Medium)

    if self.currentPage >= 1 and self.currentPage <= self.totalPages then
        local page = self.pages[self.currentPage]
        if page and page.lines and #page.lines > 0 then
            local title = page.title or "Untitled"
            renderColoredText(self, title, 10, 40, UIFont.Medium)

            local y = 40 + fontHeightMedium + 5
            for i, lineData in ipairs(page.lines) do
                local x = 10 + (lineData.indent or 0)
                if title == getText("UI_Manual_TOC_Title") then
                    if lineData.type == "toc" then
                        local titleText = lineData.title
                        local actualPageNum = lineData.pageNum + self.tocPageCount
                        local pageNumText = tostring(actualPageNum)
                        local visibleTitle = getVisibleText(titleText)
                        local titleWidth = getTextManager():MeasureStringX(UIFont.Small, visibleTitle)
                        local pageNumWidth = getTextManager():MeasureStringX(UIFont.Small, pageNumText)
                        local maxWidth = self.width - 20 - 30
                        local dotsWidth = maxWidth - titleWidth - pageNumWidth
                        local dots = string.rep(".", math.max(1, math.floor(dotsWidth / getTextManager():MeasureStringX(UIFont.Small, "."))))
                        renderColoredText(self, titleText, x, y, UIFont.Small)
                        self:drawText(dots, x + titleWidth, y, 1, 1, 1, 1, UIFont.Small)
                        self:drawText(pageNumText, self.width - 30, y, 1, 1, 1, 1, UIFont.Small)
                    end
                else
                    renderColoredText(self, lineData.text, x, y, UIFont.Small)
                end
                y = y + fontHeightSmall
            end
        else
            print("Page data not found for index " .. self.currentPage .. ", pages length: " .. #self.pages .. ", page: " .. tostring(page))
            self:drawText("Page data not found", 10, 40, 1, 1, 1, 1, UIFont.Medium)
        end
    else
        self:drawText("Page not found", 10, 40, 1, 1, 1, 1, UIFont.Medium)
    end

    local pageNumText = self.currentPage .. "/" .. self.totalPages
    self:drawText(pageNumText, self.width - 50, 10, 1, 1, 1, 1, UIFont.Small)
end

function ManualWindow:onButtonClick(button)
    if button.internal == "PREV" then
        if self.currentPage > 1 then
            self.currentPage = self.currentPage - 1
        end
    elseif button.internal == "NEXT" then
        if self.currentPage < self.totalPages then
            self.currentPage = self.currentPage + 1
        end
    elseif button.internal == "CLOSE" then
        self:close()
    end
end

function ManualWindow:close()
    self:removeFromUIManager()
end