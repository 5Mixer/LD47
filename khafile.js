let project = new Project('LD47');

project.addSources('Sources');
project.addAssets('Assets');
project.addLibrary('differ');

resolve(project);
