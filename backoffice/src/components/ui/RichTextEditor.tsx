import { useState, useRef, useCallback } from 'react'

interface RichTextEditorProps {
  value: string
  onChange: (html: string) => void
  placeholder?: string
  minHeight?: number
}

export default function RichTextEditor({ value, onChange, placeholder = 'Contenu...', minHeight = 200 }: RichTextEditorProps) {
  const editorRef = useRef<HTMLDivElement>(null)
  const [isFocused, setIsFocused] = useState(false)

  const execCmd = useCallback((command: string, value?: string) => {
    document.execCommand(command, false, value)
    if (editorRef.current) {
      onChange(editorRef.current.innerHTML)
    }
  }, [onChange])

  const handleInput = useCallback(() => {
    if (editorRef.current) {
      onChange(editorRef.current.innerHTML)
    }
  }, [onChange])

  const handlePaste = useCallback((e: React.ClipboardEvent) => {
    e.preventDefault()
    const text = e.clipboardData.getData('text/plain')
    document.execCommand('insertText', false, text)
  }, [])

  const toolbarButtons = [
    { icon: 'B', cmd: 'bold', title: 'Gras' },
    { icon: 'I', cmd: 'italic', title: 'Italique' },
    { icon: 'U', cmd: 'underline', title: 'Souligné' },
    { icon: '•', cmd: 'insertUnorderedList', title: 'Liste' },
    { icon: '1.', cmd: 'insertOrderedList', title: 'Liste numérotée' },
    { icon: 'H', cmd: 'formatBlock', value: 'h2', title: 'Titre' },
    { icon: 'P', cmd: 'formatBlock', value: 'p', title: 'Paragraphe' },
    { icon: '🔗', cmd: 'createLink', title: 'Lien', needsPrompt: true },
  ]

  return (
    <div className={`border rounded-lg overflow-hidden ${isFocused ? 'ring-2 ring-primary/30 border-primary' : 'border-border'}`}>
      <div className="flex flex-wrap gap-0.5 p-2 bg-gray-50 border-b border-border">
        {toolbarButtons.map((btn) => (
          <button
            key={btn.cmd + (btn.value || '')}
            type="button"
            title={btn.title}
            onMouseDown={(e) => {
              e.preventDefault()
              if (btn.needsPrompt) {
                const url = prompt('URL du lien:')
                if (url) execCmd(btn.cmd, url)
              } else {
                execCmd(btn.cmd, btn.value)
              }
            }}
            className="w-8 h-8 flex items-center justify-center rounded hover:bg-gray-200 text-sm font-medium text-text-main"
          >
            {btn.icon}
          </button>
        ))}
      </div>
      <div
        ref={editorRef}
        contentEditable
        suppressContentEditableWarning
        onInput={handleInput}
        onPaste={handlePaste}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
        dangerouslySetInnerHTML={{ __html: value }}
        className="p-3 text-sm text-text-main outline-none overflow-y-auto"
        style={{ minHeight }}
        data-placeholder={placeholder}
      />
      {!value && !isFocused && (
        <style>{`
          [contenteditable]:empty:before {
            content: attr(data-placeholder);
            color: #9CA3AF;
          }
        `}</style>
      )}
    </div>
  )
}
