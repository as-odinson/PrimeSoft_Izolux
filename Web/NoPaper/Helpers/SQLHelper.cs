using System;
using System.Data;
using System.Data.SqlClient;

public static class SQLHelper
{
  public static int ExecuteCommand(
      string commandText,
      SqlConnection connection,
      SqlTransaction transaction = null,
      params SqlParameter[] parameters)
  {
    if (connection == null)
      throw new ArgumentNullException(nameof(connection));

    if (string.IsNullOrWhiteSpace(commandText))
      throw new ArgumentException("SQL command is empty.", nameof(commandText));

    using (SqlCommand cmd = CreateCommand(
        commandText,
        connection,
        transaction,
        parameters))
    {
      return cmd.ExecuteNonQuery();
    }
  }

  public static object ExecuteScalar(
      string commandText,
      SqlConnection connection,
      SqlTransaction transaction = null,
      params SqlParameter[] parameters)
  {
    if (connection == null)
      throw new ArgumentNullException(nameof(connection));

    if (string.IsNullOrWhiteSpace(commandText))
      throw new ArgumentException("SQL command is empty.", nameof(commandText));

    using (SqlCommand cmd = CreateCommand(
        commandText,
        connection,
        transaction,
        parameters))
    {
      return cmd.ExecuteScalar();
    }
  }

  public static int GetIntFromSQL(
      string commandText,
      SqlConnection connection,
      SqlTransaction transaction = null,
      params SqlParameter[] parameters)
  {
    object result = ExecuteScalar(
            commandText,
            connection,
            transaction,
            parameters);

    if (result == null || result == DBNull.Value)
      return 0;

    return Convert.ToInt32(result);
  }

  public static string GetStringFromSQL(
      string commandText,
      SqlConnection connection,
      SqlTransaction transaction = null,
      params SqlParameter[] parameters)
  {
    object result = ExecuteScalar(
            commandText,
            connection,
            transaction,
            parameters);

    if (result == null || result == DBNull.Value)
      return string.Empty;

    return Convert.ToString(result);
  }

  public static bool Exists(
      string commandText,
      SqlConnection connection,
      SqlTransaction transaction = null,
      params SqlParameter[] parameters)
  {
    return GetIntFromSQL(
        commandText,
        connection,
        transaction,
        parameters) > 0;
  }

  public static DataTable GetDataTable(
      string commandText,
      SqlConnection connection,
      SqlTransaction transaction = null,
      params SqlParameter[] parameters)
  {
    if (connection == null)
      throw new ArgumentNullException(nameof(connection));

    if (string.IsNullOrWhiteSpace(commandText))
      throw new ArgumentException("SQL command is empty.", nameof(commandText));

    using (SqlCommand cmd = CreateCommand(
        commandText,
        connection,
        transaction,
        parameters))
    {
      using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
      {
        DataTable table = new DataTable();

        adapter.Fill(table);

        return table;
      }
    }
  }

  private static SqlCommand CreateCommand(
      string commandText,
      SqlConnection connection,
      SqlTransaction transaction,
      params SqlParameter[] parameters)
  {
    SqlCommand cmd = connection.CreateCommand();

    cmd.CommandText = commandText;
    cmd.CommandType = CommandType.Text;
    cmd.Transaction = transaction;
    cmd.CommandTimeout = 30;

    if (parameters != null && parameters.Length > 0)
      cmd.Parameters.AddRange(parameters);

    return cmd;
  }
}
