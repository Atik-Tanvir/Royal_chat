'use client';

import React, { useState, useRef, useEffect, useCallback } from 'react';
import {
  UploadCloud,
  Link2,
  Trash2,
  CheckCircle2,
  AlertCircle,
  FileImage,
  Sparkles,
} from 'lucide-react';

interface ImageDropzoneProps {
  value: string;
  onChange: (value: string) => void;
  label?: string;
  aspectRatioClass?: string;
  maxSizeMB?: number;
}

export function ImageDropzone({
  value,
  onChange,
  label = 'Banner Image',
  aspectRatioClass = 'aspect-[16/7]',
  maxSizeMB = 10,
}: ImageDropzoneProps) {
  const [isDragging, setIsDragging] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [imageMeta, setImageMeta] = useState<{ name: string; size?: string } | null>(null);
  const [isUrlMode, setIsUrlMode] = useState(false);
  const [urlInput, setUrlInput] = useState('');
  const [copiedPastedNotice, setCopiedPastedNotice] = useState(false);

  const fileInputRef = useRef<HTMLInputElement>(null);
  const dropzoneRef = useRef<HTMLDivElement>(null);

  // Process File into Data URL
  const processFile = useCallback(
    (file: File, source: 'upload' | 'drop' | 'paste') => {
      if (!file.type.startsWith('image/')) {
        setError('Please select an image file (PNG, JPG, WEBP, GIF, SVG).');
        return;
      }

      if (file.size > maxSizeMB * 1024 * 1024) {
        setError(`File size exceeds ${maxSizeMB}MB.`);
        return;
      }

      setError(null);
      setImageMeta({
        name: file.name || 'Pasted Image',
        size: `${(file.size / 1024).toFixed(1)} KB`,
      });

      const reader = new FileReader();
      reader.onload = (e) => {
        const result = e.target?.result as string;
        if (result) {
          onChange(result);
          if (source === 'paste') {
            setCopiedPastedNotice(true);
            setTimeout(() => setCopiedPastedNotice(false), 2000);
          }
        }
      };
      reader.onerror = () => {
        setError('Failed to read image file.');
      };
      reader.readAsDataURL(file);
    },
    [maxSizeMB, onChange]
  );

  // Listen for Clipboard Paste Event (Ctrl+V)
  useEffect(() => {
    function handlePaste(e: ClipboardEvent) {
      if (!e.clipboardData) return;

      // 1. Image file from clipboard
      const items = e.clipboardData.items;
      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        if (item.type.indexOf('image') !== -1) {
          const file = item.getAsFile();
          if (file) {
            processFile(file, 'paste');
            e.preventDefault();
            return;
          }
        }
      }

      // 2. Image URL from clipboard
      const pastedText = e.clipboardData.getData('text');
      if (
        pastedText &&
        (pastedText.startsWith('http://') ||
          pastedText.startsWith('https://') ||
          pastedText.startsWith('data:image/'))
      ) {
        if (
          /\.(jpg|jpeg|png|webp|gif|svg)(\?.*)?$/i.test(pastedText) ||
          pastedText.startsWith('data:image/') ||
          pastedText.includes('images.unsplash.com')
        ) {
          onChange(pastedText.trim());
          setImageMeta({ name: 'Pasted URL' });
          setCopiedPastedNotice(true);
          setTimeout(() => setCopiedPastedNotice(false), 2000);
        }
      }
    }

    const dropzoneElem = dropzoneRef.current;
    if (dropzoneElem) {
      dropzoneElem.addEventListener('paste', handlePaste as unknown as EventListener);
    }
    window.addEventListener('paste', handlePaste);

    return () => {
      if (dropzoneElem) {
        dropzoneElem.removeEventListener('paste', handlePaste as unknown as EventListener);
      }
      window.removeEventListener('paste', handlePaste);
    };
  }, [onChange, processFile]);

  // Drag and Drop Handlers
  function handleDragOver(e: React.DragEvent) {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(true);
  }

  function handleDragLeave(e: React.DragEvent) {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);
  }

  function handleDrop(e: React.DragEvent) {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);

    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      processFile(e.dataTransfer.files[0], 'drop');
    } else {
      const droppedText = e.dataTransfer.getData('text/plain');
      if (
        droppedText &&
        (droppedText.startsWith('http://') ||
          droppedText.startsWith('https://') ||
          droppedText.startsWith('data:image/'))
      ) {
        onChange(droppedText.trim());
        setImageMeta({ name: 'Dropped URL' });
      }
    }
  }

  function handleFileInputChange(e: React.ChangeEvent<HTMLInputElement>) {
    if (e.target.files && e.target.files.length > 0) {
      processFile(e.target.files[0], 'upload');
    }
  }

  function handleClear() {
    onChange('');
    setImageMeta(null);
    setError(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  }

  function handleApplyUrl(e: React.FormEvent) {
    e.preventDefault();
    if (!urlInput) return;
    onChange(urlInput.trim());
    setImageMeta({ name: 'URL' });
    setIsUrlMode(false);
  }

  return (
    <div className="space-y-1.5" ref={dropzoneRef} tabIndex={0}>
      <div className="flex items-center justify-between">
        <label className="block text-xs font-bold text-slate-300">{label}</label>

        <div className="flex items-center gap-2">
          {copiedPastedNotice && (
            <span className="text-[11px] font-bold text-emerald-400 flex items-center gap-1 animate-pulse">
              <Sparkles className="w-3.5 h-3.5" />
              <span>Pasted!</span>
            </span>
          )}

          <button
            type="button"
            onClick={() => setIsUrlMode(!isUrlMode)}
            className="text-[11px] font-semibold text-emerald-400 hover:text-emerald-300 flex items-center gap-1 transition-colors"
          >
            <Link2 className="w-3 h-3" />
            <span>{isUrlMode ? 'Upload' : 'URL'}</span>
          </button>
        </div>
      </div>

      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/png,image/jpeg,image/webp,image/gif,image/svg+xml"
        onChange={handleFileInputChange}
        className="hidden"
      />

      {/* Direct URL Input Mode */}
      {isUrlMode ? (
        <div className="flex gap-2">
          <input
            type="url"
            value={urlInput}
            onChange={(e) => setUrlInput(e.target.value)}
            placeholder="https://..."
            className="flex-1 px-3 py-2 rounded-xl bg-black/50 border border-white/10 text-xs text-white focus:outline-none focus:border-emerald-500 font-mono"
          />
          <button
            type="button"
            onClick={handleApplyUrl}
            className="px-3.5 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs transition-colors"
          >
            Apply
          </button>
        </div>
      ) : null}

      {/* Preview when image is present */}
      {value ? (
        <div className="relative rounded-2xl overflow-hidden border border-[#1C3830] bg-slate-950 group">
          <div className={`relative w-full ${aspectRatioClass} overflow-hidden bg-black/60`}>
            <img
              src={value}
              alt="Preview"
              className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-[1.02]"
              onError={() => setError('Failed to display image.')}
            />

            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-black/30 pointer-events-none" />

            {/* Top Bar inside preview */}
            <div className="absolute top-2 left-2.5 right-2.5 flex items-center justify-between pointer-events-auto">
              <span className="px-2 py-0.5 rounded-full bg-emerald-500/90 text-slate-950 font-black text-[10px] flex items-center gap-1">
                <CheckCircle2 className="w-3 h-3" />
                <span>Ready</span>
              </span>

              <div className="flex items-center gap-1.5">
                <button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  className="px-2.5 py-1 rounded-lg bg-black/70 hover:bg-black/90 text-white text-[11px] font-bold border border-white/20 transition-all flex items-center gap-1"
                >
                  <UploadCloud className="w-3.5 h-3.5 text-emerald-400" />
                  <span>Replace</span>
                </button>
                <button
                  type="button"
                  onClick={handleClear}
                  className="p-1.5 rounded-lg bg-rose-500/80 hover:bg-rose-500 text-white transition-all shadow-md"
                  title="Remove"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>

            {/* Bottom Meta Bar inside preview */}
            <div className="absolute bottom-2 left-2.5 right-2.5 flex items-center justify-between text-white text-[11px] pointer-events-none">
              <div className="flex items-center gap-1.5 truncate max-w-[70%]">
                <FileImage className="w-3.5 h-3.5 text-emerald-400 flex-shrink-0" />
                <span className="truncate font-semibold">{imageMeta?.name || 'Banner'}</span>
              </div>
              {imageMeta?.size && (
                <span className="text-[10px] text-slate-300 font-mono px-1.5 py-0.5 rounded bg-black/60 border border-white/10">
                  {imageMeta.size}
                </span>
              )}
            </div>
          </div>
        </div>
      ) : (
        /* Minimal Clean Dropzone */
        <div
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          onClick={() => fileInputRef.current?.click()}
          className={`relative rounded-2xl border border-dashed py-7 px-4 transition-all cursor-pointer text-center select-none ${
            isDragging
              ? 'border-emerald-400 bg-emerald-500/10 scale-[1.01]'
              : 'border-[#1C3830] hover:border-emerald-500/50 bg-black/30 hover:bg-black/50'
          }`}
        >
          <div className="flex flex-col items-center justify-center space-y-2">
            <div
              className={`w-10 h-10 rounded-xl flex items-center justify-center transition-all ${
                isDragging
                  ? 'bg-emerald-500 text-slate-950 scale-110'
                  : 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/30'
              }`}
            >
              <UploadCloud className="w-5 h-5" />
            </div>

            <p className="text-xs font-semibold text-slate-300">
              {isDragging ? 'Drop image here' : 'Drop image, paste or click to upload'}
            </p>
          </div>
        </div>
      )}

      {/* Error Notice */}
      {error && (
        <div className="flex items-center gap-1.5 p-2 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-400 text-xs font-semibold">
          <AlertCircle className="w-4 h-4 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}
    </div>
  );
}
