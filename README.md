# Godot-TopDown-Camera2d
A smooth top-down camera solution with pan and cursor-centric zoom. Features include mouse cursor-based zooming, boundary limits, and smooth transitions using interpolation.

# Installation
Install from the AssetLib or download archive from Github releases and extract `addons` directory to your project directory. 
Activate plugin in `Project` → `Project Settings` → `Plugins`

# Usage
1. After activating the plugin, add a new "TopDownCamera2D" node to your scene.

2. Configure input actions in `Project` → `Project Settings` → `Input Map`:
   - Add a `drag` action
   - Add a `zoomIn` action
   - Add a `zoomOut` action

3. Configure the camera properties in the Inspector panel.

4. Make the TopDownCamera2D node current to use it as the active camera in your scene.

<br>

---


# Features
## Smooth Cursor-Centric Zoom and Pan
<table>
    <tr>
        <td align="center">      
            <video src="https://github.com/user-attachments/assets/495a9226-a0f9-46aa-a5ec-dd2dd4e7c8dd"/> 
        </td>
    </tr>
</table>

## Visual Boundary Configuration

![Image](https://github.com/user-attachments/assets/f9b6d64c-194b-4fb5-ae49-af63dcb224e9)

# Planned Features

- Edge Scrolling: Automatically pan the camera when the mouse cursor approaches the screen edges.
- Keyboard Control: Support for keyboard inputs to pan and zoom.
- Touch Controls: Add pinch-to-zoom and drag-to-pan functionality for mobile devices.