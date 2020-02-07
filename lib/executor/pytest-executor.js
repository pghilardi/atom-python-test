'use babel';

const {BufferedProcess} = require('atom');

export default class PytestExecutor {

    constructor(dock){
      this.dock = dock;
    }

    executePyTest(filePath, pythonCommandPath, additionalArgs){
      tmp = require('tmp');
      testResultsFilename = tmp.fileSync({prefix: 'results', keep : true, postfix: '.xml'});
      args = ['-m', 'pytest', filePath, '--junit-xml=' + testResultsFilename.name];

      if (additionalArgs) {
        console.log('Considering the additional args...')
        var args = args.concat(additionalArgs.split(" "));
      }

      error = null;

      command = pythonCommandPath;
      process = new BufferedProcess({
        command,
        args,
        stdout: (out) => {
        },
        stderr: (out) => {
          error = out;
        },
        exit: (status) => {
          if (!error){
            junitViewer = require('junit-viewer');
            parsedResults = junitViewer.parse(testResultsFilename.name);
            this.dock.printOutput(parsedResults);
          } else {
            this.dock.printError(error);
          }

        }
      });

    }

}
