enum SortDirection {
  descending,
  ascending;

  SortDirection get opposite => switch (this) {
    SortDirection.descending => SortDirection.ascending,
    SortDirection.ascending => SortDirection.descending,
  };
}
