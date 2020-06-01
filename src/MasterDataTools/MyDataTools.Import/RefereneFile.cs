namespace MyDataTools.Import
{
    internal class ReferenceFile
    {
        public string RealtivePath { get; set; }
        public string FullPath { get; set; }
        public string Schema { get; internal set; }
        public string Table { get; internal set; }
    }
}