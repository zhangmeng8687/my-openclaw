---
name: lottie-optimizer
description: "Optimize Lottie JSON/JS animation files by compressing embedded images to reduce file size while preserving visual quality."
---

# Lottie Optimizer

Optimize Lottie animation files (`.json` or `.js` with `module.exports`) that contain embedded base64 images. Typical reduction: **70-90%** with no visible quality loss.

## When to Use

- Lottie animation file > 100KB
- File contains `data:image/png;base64,...` embedded images
- User wants to reduce mini-program/app bundle size

## Diagnosis

Check if the file has embedded images and how much space they take:

```bash
# Count embedded images
grep -oP "'data:image/[^']+'" file.js | wc -l

# Calculate total image size vs file size
grep -oP "'data:image/[^']+'" file.js | awk -F',' '{print length($2)}' | awk '{sum+=$1} END {print sum/1024 "KB in " NR " images"}'

# Check file total size
wc -c file.js
```

If embedded images占 > 50% of file size, optimization is worthwhile.

## Optimization Workflow

### Step 1: Check if images use transparency

```javascript
const {Jimp} = require('jimp');  // npm install jimp

const image = await Jimp.read(buffer);
const pixels = image.bitmap.data;
let hasAlpha = false;
for (let i = 3; i < pixels.length; i += 4) {
  if (pixels[i] < 255) { hasAlpha = true; break; }
}
```

- **Has transparency** → Must keep PNG format
- **No transparency** → Can convert to JPEG for better compression

### Step 2: Determine target image size

The display canvas size in the Lottie metadata (`w` and `h` fields) is the reference. Target image dimensions should be:
- **Equal to or slightly larger** than the display canvas size
- Common targets: 120×120, 150×150, 180×180

### Step 3: Resize and compress

```javascript
const {Jimp} = require('jimp');
const fs = require('fs');

const image = await Jimp.read(originalBuffer);
const resized = image.resize({w: targetSize, h: targetSize});
const optimized = await resized.getBuffer('image/png');
const newBase64 = optimized.toString('base64');
```

### Step 4: Update metadata

After resizing images, update the `w` and `h` fields in the `assets` array to match the new dimensions:

```javascript
// Before
{ id: 'image_3', w: 468, h: 468, ... }

// After (if resized to 120×120)
{ id: 'image_3', w: 120, h: 120, ... }
```

### Step 5: Write optimized file and verify

- Always backup original file first
- Verify with `node -c file.js` (syntax check)
- Test in the actual app to confirm visual quality

## Quick Script

```javascript
const {Jimp} = require('jimp');
const fs = require('fs');

const inputFile = 'path/to/animation.js';
const targetSize = 120;  // Adjust based on display canvas size

async function optimize() {
  // Backup
  fs.copyFileSync(inputFile, inputFile + '.bak');
  
  let content = fs.readFileSync(inputFile, 'utf-8');
  const regex = /'data:image\/png;base64,([^']+)'/g;
  let match;
  const matches = [];
  
  while ((match = regex.exec(content)) !== null) {
    matches.push({match});
  }
  
  for (const {match} of matches) {
    const buffer = Buffer.from(match[1], 'base64');
    if (buffer.length < 5000) continue;  // Skip small images
    
    const image = await Jimp.read(buffer);
    const resized = image.resize({w: targetSize, h: targetSize});
    const pngBuffer = await resized.getBuffer('image/png');
    const newUri = `'data:image/png;base64,${pngBuffer.toString('base64')}'`;
    content = content.replace(match[0], newUri);
  }
  
  // Update metadata for large images
  content = content.replace(
    /id: 'image_(\d+)',\s*w: \d+,\s*h: \d+/g,
    (m, id) => `id: 'image_${id}',\n      w: ${targetSize},\n      h: ${targetSize}`
  );
  
  fs.writeFileSync(inputFile, content);
  
  const original = fs.statSync(inputFile + '.bak').size;
  const optimized = fs.statSync(inputFile).size;
  console.log(`${(original/1024).toFixed(1)}KB → ${(optimized/1024).toFixed(1)}KB (${((1-optimized/original)*100).toFixed(1)}% reduction)`);
}

optimize();
```

## Results Reference

| Original Size | Target Dimensions | Typical Result |
|---|---|---|
| 468×468 | 234×234 | -70% |
| 468×468 | 180×180 | -91% |
| 468×468 | 150×150 | -94% |
| 468×468 | 120×120 | -96% |

## Cautions

- Always backup before optimization
- If images use transparency, do NOT convert to JPEG
- Verify visual quality after optimization
- Some Lottie players may have issues with non-PNG formats
- If animation uses `assetsPath` for external images, this method doesn't apply
