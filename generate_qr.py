import qrcode
from PIL import Image

# Create QR code with high error correction to allow logo overlay
qr = qrcode.QRCode(
    version=4,
    error_correction=qrcode.constants.ERROR_CORRECT_H,  # High error correction (30%)
    box_size=10,
    border=4,
)
qr.add_data('https://app.odadee.net')
qr.make(fit=True)

# Create QR code image - BLACK background, WHITE code
qr_img = qr.make_image(fill_color='white', back_color='black').convert('RGBA')

# Load and resize the Presec logo (dark mode)
logo = Image.open('assets/images/presec_logo.webp').convert('RGBA')

# Calculate logo size (about 25% of QR code)
qr_width, qr_height = qr_img.size
logo_max_size = qr_width // 4

# Resize logo while maintaining aspect ratio
logo_ratio = logo.width / logo.height
if logo_ratio > 1:
    new_width = logo_max_size
    new_height = int(logo_max_size / logo_ratio)
else:
    new_height = logo_max_size
    new_width = int(logo_max_size * logo_ratio)

logo = logo.resize((new_width, new_height), Image.LANCZOS)

# Create black background for logo (square with padding) - matches QR background
padding = 15
bg_size = max(new_width, new_height) + padding * 2
logo_bg = Image.new('RGBA', (bg_size, bg_size), 'black')

# Center logo on background
logo_x = (bg_size - new_width) // 2
logo_y = (bg_size - new_height) // 2
logo_bg.paste(logo, (logo_x, logo_y), logo)

# Calculate position to center logo on QR code
pos_x = (qr_width - bg_size) // 2
pos_y = (qr_height - bg_size) // 2

# Paste logo onto QR code
qr_img.paste(logo_bg, (pos_x, pos_y))

# Save the final image
qr_img.save('assets/qr_code_odadee.png')
print('Dark mode QR code with Presec logo saved to assets/qr_code_odadee.png')
print(f'QR code size: {qr_width}x{qr_height}')

