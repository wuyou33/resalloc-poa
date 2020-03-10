%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
%   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
%   All rights reserved. See LICENSE file in the project root for full license information.
%
%   Description:
%   Computes the price-of-anarchy of polynomial congestion games with
%   latencies obtained as linear combination of basis {b_1(x),...,b_m(x)},
%   and n players
%   
%       INPUTS:
%       Variable    Size        Description
%       `n`         1x1 int     Number of players
%       `B`         mxn real    Resource cost functions, each row 
%                               corresponds to a basis in {b_1(x),...,b_m(x)}
%       `f`         mxn real    Resource cost functions used to evaluate
%                               equilibrium condition
%       `platform`  struct      Choice of solver and options
%
%                             - platform.solver  
%                               1 (uses matlab linprog solver) or
%                               0 (uses YALMIP interface) 
%                               
%                             - platform.matlabOptions sets solver options
%                               for linprog (only if platform.solver = 1) 
%                               Example: platform.matlabOptions = 
%                                   optimoptions('linprog','Algorithm', ...
%                                   'dual-simplex');
%
%                             - platform.yalmipOptions sets solver options
%                               for YALMIP (only if platform.solver = 0) 
%                               Example: platform.yalmipOptions =
%                                   sdpsettings('solver', 'gurobi')
%
%       OUTPUTS:
%       Variable    Size        Description
%       `poa`       1x1 real    Price of anarchy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function poa = computeCostMinPoA(n, B, f, platform)
    
    % Solver options
    if platform.solver == 1 
        % to use Matlab built in LinProg with options
        platform.name = 'matlab-built-in'; 
        platform.options = platform.matlabOptions;
        fprintf('\n')
        warning(sprintf('\nYou are using the matlab linprog solver.\nWe recommend YALMIP + your favorite solver for accuracy.\nTo use YALMIP, set platform.solver=0\n'));

    elseif platform.solver == 0
        % to use YALMIP with options
        platform.name = 'YALMIP'; 
        platform.options = platform.yalmipOptions;

    else, error('Wrong choice of solver');

    end
    
    % handy expressions used to call solver
    m = size(B,1);
    f = f';
    c = repmat((1:n)', [1 m]).*(B');
    
    % solve linear program to compute price of anarchy
    [x, ~, exitflag, output] = dualLP(n, [zeros(1,m); c; zeros(1,m)], [zeros(1,m); f; zeros(1,m)], 1,  platform);
    
    if exitflag ~= 1
        error(output.message)
    end
    
    poa = 1/x(end);
end