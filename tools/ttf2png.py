#!/usr/bin/env python
# usage:
#  $ python ttf2png.py awesomefont_test.ttf 10 awesomefontglyphs.png > awesomefontwidths.txt
#
import sys
import pygame

TRANSFORM = {'2':'1', '1':'2'}

def main(argv):
    pygame.font.init()
    args = argv[1:]
    path = args.pop(0)
    size = int(args.pop(0))
    outpath = args.pop(0)
    font = pygame.font.Font(path, size)
    sizes = []
    for i in xrange(32, 127):
        c = unichr(i)
        c = TRANSFORM.get(c,c)
        sizes.append((c, font.size(c)))
    height = font.get_height()
    width = sum( w for (c,(w,h)) in sizes )
    surface = pygame.Surface((width, height), flags=pygame.SRCALPHA)
    surface.fill((0,0,0,0))
    x = 0
    r = []
    for (c,(w,h)) in sizes:
        b = font.render(c, 0, (0,0,0,255))
        r.append(x)
        surface.blit(b, (x, 0))
        x += w
    r.append(x)
    pygame.image.save(surface, outpath)
    print r
    return 0

if __name__ == '__main__': sys.exit(main(sys.argv))
