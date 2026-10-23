# Arch Linux Dotfiles

Configuraciones personales para un entorno de escritorio basado en **Arch Linux y Hyprland**.

El repositorio reúne configuraciones de apariencia, paneles, terminal, lanzadores, fondos de pantalla y una interfaz personalizada con Quickshell.

## Contenido

| Carpeta | Descripción |
|---|---|
| `hypr/` | Hyprland, Hyprlock, Hypridle, Hyprpaper y scripts auxiliares. |
| `waybar/` | Panel, módulos y estilos CSS. |
| `quickshell/` | Interfaz personalizada, componentes QML y servicios del escritorio. |
| `kitty/` | Configuración de la terminal Kitty y colores. |
| `rofi/` | Lanzador, temas y selector de fondos de pantalla. |
| `wallust/` | Configuración y plantillas para generar paletas de colores. |
| `waypaper/` | Configuración del selector de fondos de pantalla. |
| `wofi/` | Configuración y estilos de Wofi. |
| `btop/` | Configuración del monitor de recursos Btop. |

## Requisitos

Necesitarás Arch Linux o una distribución compatible y las aplicaciones correspondientes a las configuraciones que quieras utilizar:

- Hyprland
- Waybar
- Quickshell
- Kitty
- Rofi
- Wallust
- Waypaper
- Wofi
- Btop

Algunas funciones también pueden requerir Hyprlock, Hypridle, Hyprpaper, fuentes, iconos y otras dependencias utilizadas por los scripts.

No es necesario instalar todas las aplicaciones si solo quieres utilizar una parte del repositorio.

## Instalación

### 1. Descargar el repositorio

```bash
git clone https://github.com/runebenhook/dotfiles.git
cd dotfiles
```

### 2. Hacer una copia de seguridad

Antes de copiar configuraciones, guarda las que ya tengas:

```bash
mkdir -p ~/.config-backup
cp -a ~/.config ~/.config-backup/config-$(date +%Y%m%d-%H%M%S)
```

### 3. Copiar las configuraciones necesarias

Por ejemplo, para utilizar Hyprland y Waybar:

```bash
cp -a hypr waybar ~/.config/
```

Puedes copiar otras carpetas de la misma manera. Si ya tienes configuraciones con esos nombres, revisa sus diferencias antes de mezclarlas o reemplazarlas.

**No reemplaces toda tu carpeta `~/.config` por este repositorio.**

### 4. Adaptar los archivos

Antes de utilizar la configuración, revisa lo siguiente:

- **Monitor:** adapta el nombre del monitor a tu equipo, por ejemplo `eDP-1`.
- **Fondo de pantalla:** la configuración de Hyprpaper utiliza `~/Wallpapers/wallpaper.png` como ruta de ejemplo. Coloca tu imagen ahí o modifica la ruta.
- **Programas:** comprueba que los comandos de los atajos existan en tu sistema.
- **Fuentes e iconos:** instala los que necesiten los temas.
- **Quickshell:** revisa sus módulos, dependencias y scripts antes de iniciarlo.
- **Wallust:** comprueba las rutas de las plantillas y la configuración de generación de colores.

### 5. Aplicar los cambios

Recarga las aplicaciones o reinicia tu sesión de Hyprland cuando corresponda. Si tienes problemas, restaura la copia de seguridad.

## Advertencias

- Estas configuraciones se comparten como punto de partida; no constituyen un instalador automático.
- El resultado puede variar según el hardware, las versiones de los programas y las dependencias instaladas.
- Revisa los scripts antes de ejecutarlos.
- No se garantiza que todos los módulos funcionen sin modificaciones en otro equipo.

## Licencia

Este repositorio no declara una licencia general para todas las configuraciones. Antes de redistribuirlo o reutilizar sus componentes, revisa las licencias de terceros y define una licencia para el contenido propio si corresponde.
