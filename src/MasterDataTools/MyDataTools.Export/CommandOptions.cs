using CommandLine;

namespace MyDataTools.Export
{
    public class CommandOptions
    {
        [Option('c', "connection", Required = true)]
        public string ConnectionString { get; set; }

        [Option('o', "output", Default = @".\Results")]
        public string OutputPath { get; set; }

        [Option('p', "pattern", Default = @"[{0}].[{1}].json")]
        public string Pattern { get; set; }
    }
}
