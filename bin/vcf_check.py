import sys
import subprocess
import shutil

def main():
    with open(sys.argv[1], "r") as infi, open(sys.argv[1] + ".temp.txt", "w") as ofi:
        for line in infi:
            if line.startswith("#"):
                ofi.write(line)
                continue
            else:
                tokens = line.split("\t")
                ## Our issue lies in the info column, so we must split that
                ## and ensure it has the right number of tokens.
                #info = tokens[7]
                #info_tokens = info.split(";")
                if len(tokens) < 8 :
                    sys.stderr.write("Discarded line.\n")
                    continue
                else:
                    ofi.write(line)
    shutil.move( sys.argv[1] + ".temp.txt", sys.argv[1])

main()
