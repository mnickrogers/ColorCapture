# ColorCapture
A set of tools for extracting dominant colors from clothing. Enables color analysis and manipulation in iOS.

## File Descriptions
### Analysis.swift
Analysis contains the color analyzer used to extract dominant colors from clothing. It also contains helper functions for color analysis, such as determining how much two colors differ from each other and how bright or dark two colors are in comparison.

### Structures.swift
Structures contains the basic color types used by the analyzer and throughout color analysis. RGB represents colors as floating values of red, green and blue while HSL represents colors by their hue, saturation and luminance.

### Extensions.swift
Extensions is a wrapper for the major color analysis functions. It contains extensions for UIColor and UIImage. The UIColor extensions utilize the underlying color utilities found in the Analysis file, while the UIImage extensions wrap some of the analysis functions from the Analysis file. The UIImage extensions also include useful and accurate tools for cropping images that "just works" and resizing images.
