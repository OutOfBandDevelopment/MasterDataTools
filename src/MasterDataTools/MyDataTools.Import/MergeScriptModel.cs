namespace MyDataTools.Import
{
    internal class MergeScriptModel
    {
        public string RealtivePath { get; set; }
        public string FullPath { get; set; }
        public string Schema { get; set; }
        public string Table { get; set; }
        public string Before { get; set; }
        public string After { get; set; }
        public string Body { get; set; }
    }
}