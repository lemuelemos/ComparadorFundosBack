#' Cria uma conexão de pool com um banco de dados PostgreSQL
#'
#' Esta função cria e retorna uma conexão de pool com um banco de dados PostgreSQL.
#' O pool de conexão ajuda a gerenciar eficientemente as conexões de banco de dados.
#'
#' @return Um objeto de conexão de pool.
#' @import pool
#' @import RPostgres
#' @examples
#' pool()
#' # Retorna: Uma conexão de pool com o banco de dados PostgreSQL.
#' @export
pool <- function() {
  pool::dbPool(
    RPostgres::Postgres(),
    dbname = 'comparadorDB',
    host = 'localhost',
    port = 5432,
    user = 'postgres',
    password = 'postgres'
  )
}


