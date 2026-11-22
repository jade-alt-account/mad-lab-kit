# ui.py: print the centre of the first UI element whose text or
# content-desc contains the given words (from a uiautomator dump)
import re, sys
import xml.etree.ElementTree as ET

root = ET.parse(sys.argv[1]).getroot()
want = sys.argv[2]
for node in root.iter('node'):
    label = ' '.join(node.get(k) or '' for k in ('text', 'content-desc', 'hint'))
    if want in label:
        x1, y1, x2, y2 = map(int, re.findall(r'\d+', node.get('bounds')))
        print((x1 + x2) // 2, (y1 + y2) // 2)
        sys.exit(0)
sys.exit(1)
