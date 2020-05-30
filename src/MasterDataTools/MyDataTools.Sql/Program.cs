using System;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace MyDataTools.Sql
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var connectionBuilder = new SqlConnectionStringBuilder()
            {
                DataSource = @"(LocalDb)\NucleusDb",
                InitialCatalog = "NucleusDb",
                IntegratedSecurity = true,
            };

            using var sqlConn = new SqlConnection(connectionBuilder.ToString());
            await sqlConn.OpenAsync();
            using var cmd = new SqlCommand(Commands.ListTables, sqlConn);
            using var reader = cmd.ExecuteReader();

            while (await reader.ReadAsync())
            {
                var fileName = $"[{reader["Schema"] as string}].[{reader["Table"] as string}].json";
                Console.Write(fileName);
                using (var sqlConn2 = new SqlConnection(connectionBuilder.ToString()))
                {
                    await sqlConn2.OpenAsync();
                    using (var cmd2 = new SqlCommand(reader["JsonScript"] as string, sqlConn2))
                    using (var reader2 = cmd2.ExecuteReader())
                    {
                        var ret = new StringBuilder();
                        while (reader2.Read())
                        {
                            Console.Write("+");
                            ret.Append(reader2[0] as string);
                        }

                        if (!string.IsNullOrWhiteSpace(ret.ToString()))
                        File.WriteAllText(fileName, ret.ToString());
                    }
                }
                Console.WriteLine();
            }
        }
    }

    public static class Commands
    {
        public static string ListTables =
@"
SELECT 
	[schemas].[name] AS [Schema],
    [tables].[name] AS [Table], 
	'SELECT * FROM [' + [schemas].[name] + '].[' + [tables].[name] + '] FOR JSON AUTO' AS [JsonScript],
	'SELECT * FROM [' + [schemas].[name] + '].[' + [tables].[name] + '] FOR XML AUTO' AS [XmlScript]
FROM [sys].[schemas]
INNER JOIN [sys].[tables]
	ON [tables].[schema_id] = [schemas].[schema_id]
WHERE 
	[schemas].[name] != 'dbo'
ORDER BY
	[schemas].[name],
	[tables].[name]";

    }
}
