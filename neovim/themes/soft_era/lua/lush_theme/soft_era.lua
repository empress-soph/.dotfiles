--
-- Built with,
--
--        ,gggg,
--       d8" "8I                         ,dPYb,
--       88  ,dP                         IP'`Yb
--    8888888P"                          I8  8I
--       88                              I8  8'
--       88        gg      gg    ,g,     I8 dPgg,
--  ,aa,_88        I8      8I   ,8'8,    I8dP" "8I
-- dP" "88P        I8,    ,8I  ,8'  Yb   I8P    I8
-- Yb,_,d88b,,_   ,d8b,  ,d8b,,8'_   8) ,d8     I8,
--  "Y8P"  "Y888888P'"Y88P"`Y8P' "YY8P8P88P     `Y8
--

-- This is a starter colorscheme for use with Lush,
-- for usage guides, see :h lush or :LushRunTutorial

--
-- Note: Because this is a lua file, vim will append it to the runtime,
--       which means you can require(...) it in other lua code (this is useful),
--       but you should also take care not to conflict with other libraries.
--
--       (This is a lua quirk, as it has somewhat poor support for namespacing.)
--
--       Basically, name your file,
--
--       "super_theme/lua/lush_theme/super_theme_dark.lua",
--
--       not,
--
--       "super_theme/lua/dark.lua".
--
--       With that caveat out of the way...
--

-- Enable lush.ify on this file, run:
--
--  `:Lushify`
--
--  or
--
--  `:lua require('lush').ify()`

local lush = require('lush')
local hsl = lush.hsl

-- LSP/Linters mistakenly show `undefined global` errors in the spec, they may
-- support an annotation like the following. Consult your server documentation.
---@diagnostic disable: undefined-global
local theme = lush(function(injected_functions)
  local sym = injected_functions.sym
  return {
    -- The following are the Neovim (as of 0.8.0-dev+100-g371dfb174) highlight
    -- groups, mostly used for styling UI elements.
    -- Comment them out and add your own properties to override the defaults.
    -- An empty definition `{}` will clear all styling, leaving elements looking
    -- like the 'Normal' group.
    -- To be able to link to a group, it must already be defined, so you may have
    -- to reorder items as you go.
    --
    -- See :h highlight-groups
    --
    ColorColumn { bg="#f2edec" }, -- Columns set with 'colorcolumn'
    Conceal { fg="nvimlightgrey4" }, -- Placeholder characters substituted for concealed text (see 'conceallevel')
    Cursor { fg="bg", bg="#eeaabe" }, -- Character under the cursor
    CurSearch { fg="nvimlightgrey1", bg="nvimdarkyellow" }, -- Highlighting a search pattern under the cursor (see 'hlsearch')
    -- lCursor { fg="bg", bg="fg" }, -- Character under the cursor when |language-mapping| is used (see 'guicursor')
    CursorIM { fg="#ff0000", bg="#00ff00" }, -- Like Cursor, but used when in IME mode |CursorIM|
    CursorColumn { bg="#f2edec" }, -- Screen-column at the cursor, when 'cursorcolumn' is set.
    CursorLine { bg="#f2edec" }, -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
    Directory { fg="#25b7b8" }, -- Directory names (and other special names in listings)
    DiffAdd { bg="#98c4ba" }, -- Diff mode: Added line |diff.txt|
    DiffChange { bg="#ede7c5" }, -- Diff mode: Changed line |diff.txt|
    DiffDelete { bg="#db90a7" }, -- Diff mode: Deleted line |diff.txt|
    DiffText { gui="reverse" }, -- Diff mode: Changed text within a changed line |diff.txt|
    TermCursor { gui="reverse" }, -- Cursor in a focused terminal
    -- TermCursorNC   { }, -- Cursor in an unfocused terminal
    ErrorMsg { fg="#dd698c", gui="reverse" }, -- Error messages on the command line
    VertSplit { fg="#f9f5f5", bg="#f9f5f5" }, -- Column separating vertically split windows
    Folded { fg="#e2d1d1" }, -- Line used for closed folds
    FoldColumn { fg="#ff0000", bg="#00ff00" }, -- 'foldcolumn'
    SignColumn { fg="#e2d1d1", bg="#f9f5f5" }, -- Column where |signs| are displayed
    IncSearch { bg="#eeaabe", gui="underline" }, -- 'incsearch' highlighting; also used for the text replaced with ":s///c"
    LineNr { fg="#e2d1d1" }, -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
    LineNrAbove { LineNr }, -- Line number for when the 'relativenumber' option is set, above the cursor line
    LineNrBelow { LineNr }, -- Line number for when the 'relativenumber' option is set, below the cursor line
    CursorLineNr { fg="#b4addf" }, -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
    CursorLineFold { FoldColumn }, -- Like FoldColumn when 'cursorline' is set for the cursor line
    CursorLineSign { SignColumn }, -- Like SignColumn when 'cursorline' is set for the cursor line
    MatchParen { fg="#82b4e3", gui="bold" }, -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
    ModeMsg { fg="#ff0000", bg="#00ff00" }, -- 'showmode' message (e.g., "-- INSERT -- ")
    Normal { fg="#c8b3b3", bg="#f9f5f5" }, -- Normal text
    NormalFloat { bg="nvimlightgrey1" }, -- Normal text in floating windows.
    -- NormalNC       { }, -- normal text in non-current windows
    Pmenu { fg="#a29acb", bg="#eceafa" }, -- Popup menu: Normal item.
    PmenuSel { fg="#a29acb", bg="#cfc8f4", blend=0 }, -- Popup menu: Selected item.
    PmenuKind { Pmenu }, -- Popup menu: Normal item "kind"
    PmenuKindSel { PmenuSel }, -- Popup menu: Selected item "kind"
    PmenuExtra { Pmenu }, -- Popup menu: Normal item "extra text"
    PmenuExtraSel { PmenuSel }, -- Popup menu: Selected item "extra text"
    PmenuSbar { fg="#ff0000", bg="#00ff00" }, -- Popup menu: Scrollbar.
    PmenuThumb { fg="#ff0000", bg="#00ff00" }, -- Popup menu: Thumb of the scrollbar.
    Question { fg="#00ff00" }, -- |hit-enter| prompt and yes/no questions
    QuickFixLine { fg="nvimdarkcyan" }, -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
    Search { bg="#e2d1d1", gui="underline" }, -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
    Substitute { Search }, -- |:substitute| replacement text highlighting
    SpecialKey { fg="#ff0000", bg="#00ff00" }, -- Unprintable characters: text displayed differently from what it really is. But not 'listchars' whitespace. |hl-Whitespace|
    SpellBad { sp="nvimdarkred", fg="#ff0000", bg="#00ff00" }, -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
    SpellCap { sp="nvimdarkyellow", fg="#ff0000", bg="#00ff00" }, -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
    SpellLocal { sp="nvimdarkgreen", fg="#ff0000", bg="#00ff00" }, -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
    SpellRare { sp="nvimdarkcyan", fg="#ff0000", bg="#00ff00" }, -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.
    StatusLine { fg="#ff0000", bg="#00ff00" }, -- Status line of current window
    StatusLineNC { fg="#ff0000", bg="#00ff00" }, -- Status lines of not-current windows. Note: If this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
    -- MsgArea        { }, -- Area for messages and cmdline
    MsgSeparator { StatusLine }, -- Separator for scrolled messages, `msgsep` flag of 'display'
    MoreMsg { fg="#ff0000", bg="#00ff00" }, -- |more-prompt|
    NonText { fg="#d8d0cb" }, -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
    EndOfBuffer { NonText }, -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
    TabLine { fg="#a29acb", bg="#cfc8f4" }, -- Tab pages line, not active tab page label
    TabLineFill { fg="#a29acb", bg="#cfc8f4" }, -- Tab pages line, where there are no labels
    TabLineSel { fg="#948484", bg="#f9f5f5" }, -- Tab pages line, active tab page label
    Title { fg="#a29acb", gui="bold" }, -- Titles for output from ":set all", ":autocmd" etc.
    FloatBorder { NormalFloat }, -- Border of floating windows.
    FloatTitle { Title }, -- Title of floating windows.
    Visual { bg="#eceafa" }, -- Visual mode selection
    VisualNOS { fg="#ff0000", bg="#00ff00" }, -- Visual mode selection when vim is "Not Owning the Selection".
    WarningMsg { fg="#ff0000", bg="#00ff00" }, -- Warning messages
    Whitespace { fg="#d8d0cb" }, -- "nbsp", "space", "tab" and "trail" in 'listchars'
    -- Winseparator   { }, -- Separator between window splits. Inherts from |hl-VertSplit| by default, which it will replace eventually.
    WildMenu { fg="#ff0000", bg="#00ff00" }, -- Current match in 'wildmenu' completion
    WinBar { fg="nvimdarkgrey4", bg="nvimlightgrey1", gui="bold" }, -- Window bar of current window
    WinBarNC { fg="nvimdarkgrey4", bg="nvimlightgrey1" }, -- Window bar of not-current windows

    -- Common vim syntax groups used for all kinds of code and markup.
    -- Commented-out groups should chain up to their preferred (*) group
    -- by default.
    --
    -- See :h group-name
    --
    -- Uncomment and edit if you want more specific syntax highlighting.

    Comment { fg="#9c9a9a" }, -- Any comment

    Constant { fg="#414141" }, -- (*) Any constant
    String { fg="#414141", bg="#f2edec" }, -- A string constant: "this is a string"
    Character { fg="#414141", bg="#f2edec" }, -- A character constant: 'c', '\n'
    Number { fg="#414141", bg="#f2edec" }, -- A number constant: 234, 0xff
    Boolean { fg="#ec57b4", gui="bold,italic" }, -- A boolean constant: TRUE, false
    Float { fg="#414141", bg="#f2edec" }, -- A floating point constant: 2.3e10

    Identifier { fg="#cb8dd7" }, -- (*) Any variable name
    Function { fg="#25b7b8" }, -- Function name (also: methods for classes)

    Statement { fg="#ec57b4" }, -- (*) Any statement
    Conditional { fg="#82b4e3", gui="bold,italic" }, -- if, then, else, endif, switch, etc.
    Repeat { fg="#82b4e3", gui="bold,italic" }, -- for, do, while, etc.
    Label { fg="#82b4e3", gui="bold,italic" }, -- case, default, etc.
    Operator { fg="#ec57b4" }, -- "sizeof", "+", "*", etc.
    Keyword { fg="#82b4e3", gui="bold,italic" }, -- any other keyword
    Exception { fg="#82b4e3", gui="bold" }, -- try, catch, throw

    PreProc { fg="#82b4e3", gui="bold" }, -- (*) Generic Preprocessor
    Include { fg="#82b4e3", gui="bold,italic" }, -- Preprocessor #include
    Define { fg="#82b4e3", gui="bold,italic" }, -- Preprocessor #define
    Macro { fg="#82b4e3", gui="bold" }, -- Same as Define
    PreCondit { fg="#82b4e3", gui="bold" }, -- Preprocessor #if, #else, #endif, etc.

    Type { fg="#b4addf", gui="bold,italic" }, -- (*) int, long, char, etc.
    StorageClass { fg="#b4addf", gui="bold,italic" }, -- static, register, volatile, etc.
    Structure { fg="#b4addf", gui="bold,italic" }, -- struct, union, enum, etc.
    Typedef { fg="#b4addf" }, -- A typedef

    Special { fg="#cfc8f4", gui="bold" }, -- (*) Any special symbol
    SpecialChar { fg="#414141" }, -- Special character in a constant
    Tag { fg="#414141" }, -- You can use CTRL-] on this
    Delimiter { fg="#414141" }, -- Character that needs attention
    SpecialComment { fg="#414141" }, -- Special things inside a comment (e.g. '\n')
    Debug { fg="#414141" }, -- Debugging statements

    Underlined { gui="underline" }, -- Text that stands out, HTML links
    Ignore { Normal }, -- Left blank, hidden |hl-Ignore| (NOTE: May be invisible here in template)
    Error { fg="#ffffff", bg="#dd698c" }, -- Any erroneous construct
    Todo { fg="#db90a7", gui="bold" }, -- Anything that needs extra attention; mostly the keywords TODO FIXME and XXX

    -- These groups are for the native LSP client and diagnostic system. Some
    -- other LSP clients may use these groups, or use their own. Consult your
    -- LSP client's documentation.

    -- See :h lsp-highlight, some groups may not be listed, submit a PR fix to lush-template!
    --
    LspReferenceText { Visual }, -- Used for highlighting "text" references
    -- LspReferenceRead            { } , -- Used for highlighting "read" references
    -- LspReferenceWrite           { } , -- Used for highlighting "write" references
    LspCodeLens { NonText }, -- Used to color the virtual text of the codelens. See |nvim_buf_set_extmark()|.
    -- LspCodeLensSeparator        { } , -- Used to color the seperator between two or more code lens.
    LspSignatureActiveParameter { Visual }, -- Used to highlight the active parameter in the signature help. See |vim.lsp.handlers.signature_help()|.

    -- See :h diagnostic-highlights, some groups may not be listed, submit a PR fix to lush-template!
    --
    DiagnosticError { fg="nvimdarkred" }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    DiagnosticWarn { fg="nvimdarkyellow" }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    DiagnosticInfo { fg="nvimdarkcyan" }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    DiagnosticHint { fg="nvimdarkblue" }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    DiagnosticOk { fg="nvimdarkgreen" }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    DiagnosticVirtualTextError { DiagnosticError }, -- Used for "Error" diagnostic virtual text.
    DiagnosticVirtualTextWarn { DiagnosticWarn }, -- Used for "Warn" diagnostic virtual text.
    DiagnosticVirtualTextInfo { DiagnosticInfo }, -- Used for "Info" diagnostic virtual text.
    DiagnosticVirtualTextHint { DiagnosticHint }, -- Used for "Hint" diagnostic virtual text.
    DiagnosticVirtualTextOk { DiagnosticOk }, -- Used for "Ok" diagnostic virtual text.
    DiagnosticUnderlineError { sp="nvimdarkred", gui="underline" }, -- Used to underline "Error" diagnostics.
    DiagnosticUnderlineWarn { sp="nvimdarkyellow", gui="underline" }, -- Used to underline "Warn" diagnostics.
    DiagnosticUnderlineInfo { sp="nvimdarkcyan", gui="underline" }, -- Used to underline "Info" diagnostics.
    DiagnosticUnderlineHint { sp="nvimdarkblue", gui="underline" }, -- Used to underline "Hint" diagnostics.
    DiagnosticUnderlineOk { sp="nvimdarkgreen", gui="underline" }, -- Used to underline "Ok" diagnostics.
    DiagnosticFloatingError { DiagnosticError }, -- Used to color "Error" diagnostic messages in diagnostics float. See |vim.diagnostic.open_float()|
    DiagnosticFloatingWarn { DiagnosticWarn }, -- Used to color "Warn" diagnostic messages in diagnostics float.
    DiagnosticFloatingInfo { DiagnosticInfo }, -- Used to color "Info" diagnostic messages in diagnostics float.
    DiagnosticFloatingHint { DiagnosticHint }, -- Used to color "Hint" diagnostic messages in diagnostics float.
    DiagnosticFloatingOk { DiagnosticOk }, -- Used to color "Ok" diagnostic messages in diagnostics float.
    DiagnosticSignError { DiagnosticError }, -- Used for "Error" signs in sign column.
    DiagnosticSignWarn { DiagnosticWarn }, -- Used for "Warn" signs in sign column.
    DiagnosticSignInfo { DiagnosticInfo }, -- Used for "Info" signs in sign column.
    DiagnosticSignHint { DiagnosticHint }, -- Used for "Hint" signs in sign column.
    DiagnosticSignOk { DiagnosticOk }, -- Used for "Ok" signs in sign column.

    -- Tree-Sitter syntax groups.
    --
    -- See :h treesitter-highlight-groups, some groups may not be listed,
    -- submit a PR fix to lush-template!
    --
    -- Tree-Sitter groups are defined with an "@" symbol, which must be
    -- specially handled to be valid lua code, we do this via the special
    -- sym function. The following are all valid ways to call the sym function,
    -- for more details see https://www.lua.org/pil/5.html
    --
    -- sym("@text.literal")
    -- sym('@text.literal')
    -- sym"@text.literal"
    -- sym'@text.literal'
    --
    -- For more information see https://github.com/rktjmp/lush.nvim/issues/109

    -- sym"@text.literal"      { }, -- Comment
    -- sym"@text.reference"    { }, -- Identifier
    -- sym"@text.title"        { }, -- Title
    -- sym"@text.uri"          { }, -- Underlined
    -- sym"@text.underline"    { }, -- Underlined
    -- sym"@text.todo"         { }, -- Todo
    sym"@comment" { Comment }, -- Comment
    sym"@punctuation" { Delimiter }, -- Delimiter
    sym"@constant" { Constant }, -- Constant
    sym"@constant.builtin" { Special }, -- Special
    -- sym"@constant.macro"    { }, -- Define
    -- sym"@define"            { }, -- Define
    -- sym"@macro"             { }, -- Macro
    sym"@string" { String }, -- String
    -- sym"@string.escape"     { }, -- SpecialChar
    sym"@string.special" { SpecialChar }, -- SpecialChar
    sym"@character" { Character }, -- Character
    sym"@character.special" { SpecialChar }, -- SpecialChar
    sym"@number" { Number }, -- Number
    sym"@boolean" { Boolean }, -- Boolean
    -- sym"@float"             { }, -- Float
    sym"@function" { Function }, -- Function
    sym"@function.builtin" { Special }, -- Special
    -- sym"@function.macro"    { }, -- Macro
    -- sym"@parameter"         { }, -- Identifier
    -- sym"@method"            { }, -- Function
    -- sym"@field"             { }, -- Identifier
    sym"@property" { Identifier }, -- Identifier
    sym"@constructor" { Special }, -- Special
    -- sym"@conditional"       { }, -- Conditional
    -- sym"@repeat"            { }, -- Repeat
    sym"@label" { Label }, -- Label
    sym"@operator" { Operator }, -- Operator
    sym"@keyword" { Keyword }, -- Keyword
    -- sym"@exception"         { }, -- Exception
    sym"@variable" { fg="nvimdarkgrey2" }, -- Identifier
    sym"@type" { Type }, -- Type
    -- sym"@type.definition"   { }, -- Typedef
    -- sym"@storageclass"      { }, -- StorageClass
    -- sym"@structure"         { }, -- Structure
    -- sym"@namespace"         { }, -- Identifier
    -- sym"@include"           { }, -- Include
    -- sym"@preproc"           { }, -- PreProc
    -- sym"@debug"             { }, -- Debug
    sym"@tag" { Tag }, -- Tag
  }
end)

-- Return our parsed theme for extension or use elsewhere.
return theme

-- vi:nowrap
