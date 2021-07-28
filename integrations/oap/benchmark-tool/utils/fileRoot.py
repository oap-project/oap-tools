class FileROOT:
    def __init__(self, FilePath, fileName, subFiles=[]):
        self.FilePath = FilePath
        self.fileName = fileName
        self.subFiles = subFiles

    def contains_subFile(self, fileName):
        for subfile in self.subFiles:
            if subfile.fileName == fileName:
                return True
        return False

    def remove_subFile(self, fileName):
        for subfile in self.subFiles:
            if subfile.fileName == fileName:
                self.subFiles.remove(subfile)

    def add_subFile(self, subFile):
         self.subFiles.append(subFile)

    def add_subFiles(self, subFiles_list):
        for subFile in subFiles_list:
            self.subFiles.append(subFile)

    def return_subFile(self, fileName):
        for subfile in self.subFiles:
            if subfile.fileName == fileName:
                return subfile