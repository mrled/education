def join[A](mma: F[F[A]]): F[A] = flatMap(mma)(ma => ma)
