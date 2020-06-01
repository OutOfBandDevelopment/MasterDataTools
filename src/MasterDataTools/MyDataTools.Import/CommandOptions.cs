using CommandLine;

namespace MyDataTools.Import
{
    public class CommandOptions
    {
        [Option('c', "connection", Required = true)]
        public string ConnectionString { get; set; }

        [Option('s', "source", Default = ".")]
        public string SourcePath { get; set; }

        [Option('p', "pattern", Default = @"^.*\[(?<schema>[^\]]+)\]\.\[(?<table>[^\]]+)\]\.json$")]
        public string Pattern { get; set; }

        [Option('f', "filter", Default = @"*.json")]
        public string Filter { get; set; }

        [Option('r', "recursive", Default = false)]
        public bool Recursive { get; set; }
    }
}
