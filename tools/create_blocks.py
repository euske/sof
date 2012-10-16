#!/usr/bin/env python
import sys
import pygame

class Blocks(object):

    def __init__(self, path, n=100):
        self.src = pygame.image.load(path)
        self.dst = pygame.Surface((32*n, 32), flags=pygame.SRCALPHA)
        self._i = 1
        return

    def put(self, x, y):
        src = self.src.subsurface((x*16, y*16, 16, 16))
        self.dst.blit(pygame.transform.scale(src,(32,32)), (self._i*32, 0))
        self._i += 1
        return

    def save(self, path):
        pygame.image.save(self.dst, path)
        return

def main(argv):
    b = Blocks(argv[1])
    b.put(0,1)                  # cobble stone
    b.put(21,3)                 # lava
    b.put(3,5)                  # ladder
    b.put(1,0)                  # smooth stone
    b.put(2,0)                  # dirt
    b.put(3,0)                  # dirt+grass
    b.put(4,0)                  # plank
    b.put(7,0)                  # brick
    b.put(8,0)                  # TNT
    b.put(11,0)                 # cobweb
    b.put(12,0)                 # flower red
    b.put(13,0)                 # flower yellow
    b.put(15,0)                 # sapling
    b.put(1,1)                  # bedrock
    b.put(2,1)                  # sand
    b.put(4,1)                  # wood
    b.put(6,1)                  # iron block
    b.put(7,1)                  # gold block
    b.put(8,1)                  # diamond block
    b.put(12,1)                 # mushroom red
    b.put(13,1)                 # mushroom brown
    b.put(0,2)                  # gold ore
    b.put(1,2)                  # iron ore
    b.put(2,2)                  # coal ore
    b.put(3,2)                  # bookshelf
    b.put(4,2)                  # mossy stone
    b.put(5,2)                  # obsidian
    b.put(12,2)                 # furnance
    b.put(1,3)                  # grass
    b.put(2,3)                  # diamond ore
    b.put(3,3)                  # redstone ore
    b.put(5,3)                  # leaf
    b.put(6,3)                  # smooth stone brick
    b.put(12,3)                 # crafting table
    b.put(18,3)                 # sign
    b.put(22,3)                 # water
    b.put(6,4)                  # cactus
    b.put(9,4)                  # sugar cane
    b.put(0,5)                  # torch
    b.put(1,5)                  # door upper
    b.put(1,6)                  # door lower
    b.put(19,6)                 # chest
    b.put(7,7)                  # pumpkin
    b.put(12,8)                 # cake
    b.save(argv[2])
    return

if __name__ == '__main__': sys.exit(main(sys.argv))
