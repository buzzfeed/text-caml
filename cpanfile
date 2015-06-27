requires 'Carp'         => 0;
requires 'File::Spec'   => 0;
requires 'Scalar::Util' => 0;
on 'test' => sub {
    requires 'Test::More'   => 0;
    requires 'YAML::Syck'   => 0;
};
